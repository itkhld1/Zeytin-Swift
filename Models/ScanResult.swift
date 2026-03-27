import Foundation
import SwiftUI
import UIKit 

enum ScanType {
    case liveScan
    case photoScan
}

struct PestDiseaseDetail: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let description: String
    let symptoms: String
    let mitigation: String
    let learnMoreURL: URL?

    static func == (lhs: PestDiseaseDetail, rhs: PestDiseaseDetail) -> Bool {
        lhs.id == rhs.id
    }
}

struct ScanResult: Identifiable, Equatable {
    let id: String
    let type: ScanType
    let status: String
    let description: String
    let color: Color
    var uiImage: UIImage? // Added to display in results view
    var confidence: String = "" // Added confidence
    var pestDiseaseDetail: PestDiseaseDetail? // New property for detailed pest/disease info
    
    // Conformance to Equatable (can be synthesized if all properties are Equatable)
    // For uiImage (UIImage), it's a class, so custom comparison is needed for value equality,
    // but for identity comparison, default synthesis is fine.
    // If comparing the actual image data is needed, a custom == would be required.
    // For now, comparing by ID should be sufficient for onChange purposes.
    static func == (lhs: ScanResult, rhs: ScanResult) -> Bool {
        lhs.id == rhs.id
    }
}

class ScanResultManager: ObservableObject {
    @Published var results: [ScanResult] = []
    @Published var currentScanResult: ScanResult? {
        didSet {
            // Optional: Keep a history of results
            if let newResult = currentScanResult {
                results.append(newResult)
            }
        }
    }
    
    func addResult(_ result: ScanResult) {
        self.currentScanResult = result
    }
}
