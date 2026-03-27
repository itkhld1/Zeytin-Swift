import AVFoundation
import Vision
import CoreML
import UIKit
import SwiftUI
import CoreImage

// Wrapper to make VNCoreMLModel Sendable (it is thread-safe but not marked as such in all SDKs)
struct VisionModelWrapper: @unchecked Sendable {
    let vnModel: VNCoreMLModel
}

@MainActor
final class CameraManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var predictionText: String = "Finding olives..."
    @Published var confidenceScore: String = ""
    @Published var allClassificationObservations: [(identifier: String, confidence: Float)] = [] // Changed CGFloat to Float
    @Published var currentStatusMessage: String = "Initializing camera..."
    
    // Add a property for ScanResultManager to publish results to
    @MainActor var scanResultManager: ScanResultManager?
    
    nonisolated(unsafe) var session = AVCaptureSession()
    nonisolated private let modelWrapper: VisionModelWrapper
    
    // Store the last prediction in a thread-safe way
    nonisolated(unsafe) private let lastPredictionLock = NSLock()
    nonisolated(unsafe) private var _lastPrediction: String = "Finding olives..."

    // Debouncing properties
    @MainActor private var lastPublishedScanResult: ScanResult?
    @MainActor private var currentConsecutivePrediction: String?
    @MainActor private var consecutivePredictionCount: Int = 0
    private let predictionStabilityThreshold: Int = 5 // Number of consecutive frames for a prediction to be stable

    override init() {
        let config = MLModelConfiguration()
        guard let oliveModel = try? OliveClassifier(configuration: config),
              let visionModel = try? VNCoreMLModel(for: oliveModel.model) else {
            fatalError("Could not load OliveClassifier model.")
        }
        self.modelWrapper = VisionModelWrapper(vnModel: visionModel)
        super.init()
        setupCamera()
    }

    func setupCamera() {
        // Prevent adding multiple inputs if already configured
        if session.inputs.isEmpty {
            guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: device) else { return }
            session.addInput(input)
        }
        
        // Prevent adding multiple outputs if already configured
        if session.outputs.isEmpty {
            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraQueue"))
            session.addOutput(output)
        }
        
        // Start the session on a background thread using DispatchQueue
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
            Task { @MainActor in
                self?.currentStatusMessage = "Scanning..."
            }
        }
    }
    
    nonisolated private func getLastPrediction() -> String {
        lastPredictionLock.lock()
        defer { lastPredictionLock.unlock() }
        return _lastPrediction
    }
    
    nonisolated private func setLastPrediction(_ prediction: String) {
        lastPredictionLock.lock()
        defer { lastPredictionLock.unlock() }
        _lastPrediction = prediction
    }

    /// Helper function to map prediction identifier to ScanResult
    @MainActor
    private func processClassificationResult(identifier: String, confidence: CGFloat, type: ScanType, uiImage: UIImage? = nil) -> ScanResult {
        let confidenceString = "\(Int(confidence * 100))%"
        var status: String
        var description: String
        var color: Color
        var pestDiseaseDetail: PestDiseaseDetail? = nil // New: Optional detail for pests/diseases
        
        switch identifier {
        case "Green":
            status = "Green"
            description = "These olives are young and firm, ideal for early harvest olive oil, which often has a more pungent and peppery flavor. Also good for brining if you prefer a firmer texture."
            color = .green
        case "Black":
            status = "Black"
            description = "Fully ripened olives, perfect for rich, mellow olive oil, or for curing into tender table olives. Expect a smoother, fruitier oil."
            color = .black
        case "Veraison":
            status = "Veraison"
            description = "Olives undergoing 'Veraison' are changing color from green to black. This stage is ideal for producing a balanced olive oil with both green and fruity notes."
            color = .orange
        case "Pest":
            status = "Pest"
            description = "Signs of pest infestation detected. Early intervention is crucial to save the harvest."
            color = .red
            pestDiseaseDetail = PestDiseaseDetail(
                name: "Olive Fruit Fly",
                description: "The olive fruit fly (Bactrocera oleae) is a major pest, laying eggs in the olive fruit, causing damage and reducing oil quality.",
                symptoms: "Small punctures on fruit surface, larvae inside fruit, rotting fruit.",
                mitigation: "Pheromone traps, organic insecticides (e.g., spinosad), early harvest, removal of infested fruit. Consult local agricultural extension.",
                learnMoreURL: URL(string: "https://en.wikipedia.org/wiki/Bactrocera_oleae") // Placeholder URL
            )
        case "Disease":
            status = "Disease"
            description = "Symptoms of a disease detected. This could affect the quality and yield."
            color = .red
            pestDiseaseDetail = PestDiseaseDetail(
                name: "Peacock Spot",
                description: "Peacock spot (Spilocaea oleaginea) is a fungal disease causing leaf spots, premature leaf drop, and reduced productivity.",
                symptoms: "Circular dark spots with a yellow halo on leaves, defoliation.",
                mitigation: "Pruning to improve air circulation, copper-based fungicides applied in fall and spring. Consult local agricultural expert.",
                learnMoreURL: URL(string: "https://en.wikipedia.org/wiki/Spilocaea_oleaginea") // Placeholder URL
            )
        default:
            status = "Unknown"
            description = "Could not determine the olive's status. Please try scanning again with better lighting or focus."
            color = .gray
        }
        return ScanResult(id: UUID().uuidString, type: type, status: status, description: description, color: color, uiImage: uiImage, confidence: confidenceString, pestDiseaseDetail: pestDiseaseDetail)
    }

    // Non-isolated function for capturing output (AVCaptureVideoDataOutputSampleBufferDelegate)
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // Get the current prediction in a thread-safe way
        let currentPrediction = getLastPrediction()
        
        // Accessing 'modelWrapper' is safe because it is nonisolated and Sendable
        let request = VNCoreMLRequest(model: modelWrapper.vnModel) { request, error in
            
            if let results = request.results as? [VNClassificationObservation],
               let topResult = results.first {
                
                let newPrediction = topResult.identifier
                let newConfidence = topResult.confidence

                // Prepare Sendable copy of the top observations BEFORE hopping to MainActor
                let topThreeObservations: [(identifier: String, confidence: Float)] =
                    results.prefix(3).map { obs in
                        (identifier: obs.identifier, confidence: obs.confidence)
                    }
                
                // Jump to the Main Thread for UI and Haptics
                Task { @MainActor [weak self] in
                    guard let self = self else { return }
                    
                    let newScanResult = self.processClassificationResult(identifier: newPrediction, confidence: CGFloat(newConfidence), type: .liveScan)

                    // Debouncing Logic
                    if self.currentConsecutivePrediction == newPrediction {
                        self.consecutivePredictionCount += 1
                    } else {
                        self.currentConsecutivePrediction = newPrediction
                        self.consecutivePredictionCount = 1
                    }

                    if self.consecutivePredictionCount >= self.predictionStabilityThreshold {
                        // Only add if the stable prediction is different from the last one published
                        if self.lastPublishedScanResult?.status != newScanResult.status ||
                           self.lastPublishedScanResult?.confidence != newScanResult.confidence {
                            
                            self.scanResultManager?.addResult(newScanResult)
                            self.lastPublishedScanResult = newScanResult
                        }
                        // Reset count after publishing to avoid repeated publishing of the same stable result
                        self.consecutivePredictionCount = 0
                    }

                    // 1. Only trigger haptics if the prediction has CHANGED
                    // and we are very confident (over 85%)
                    if newPrediction != currentPrediction && newConfidence > 0.85 {
                        
                        if newPrediction == "Veraison" {
                            // The "Success" vibration for Liquid Gold stage
                            HapticManager.shared.triggerSuccessHaptic()
                        } else {
                            // A light tap for other stages
                            HapticManager.shared.triggerLightImpact()
                        }
                    }
                    
                    // 2. Update the UI
                    self.predictionText = newScanResult.status // Update for LiveScanView's top status bar
                    self.confidenceScore = newScanResult.confidence // Update for LiveScanView's top status bar
                    
                    // Populate allClassificationObservations for real-time feed using Sendable copy
                    self.allClassificationObservations = topThreeObservations

                    // Update status message
                    if newScanResult.status == "Pest" || newScanResult.status == "Disease" {
                        self.currentStatusMessage = "\(newScanResult.status) Detected!"
                    } else if newScanResult.status == "Unknown" {
                        self.currentStatusMessage = "Scanning (Uncertain)..."
                    } else {
                        self.currentStatusMessage = "Scanning (\(newScanResult.status))..."
                    }
                    
                    // 3. Update the cached prediction in a thread-safe way
                    self.setLastPrediction(newPrediction)
                }
            }
        }
        
        // This runs on the background 'cameraQueue' you created in setupCamera()
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}
