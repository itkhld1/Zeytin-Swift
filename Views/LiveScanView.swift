import SwiftUI
import AVFoundation

struct LiveScanView: View {
    @EnvironmentObject var scanResultManager: ScanResultManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @StateObject var cameraManager = CameraManager()
    @State private var showingPestDiseaseDetailSheet = false
    @State private var selectedPestDiseaseDetail: PestDiseaseDetail?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                CameraView(session: $cameraManager.session)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    VStack {
                        Text("LIVE SCAN")
                            .font(horizontalSizeClass == .regular ? .title3 : .caption)
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(cameraManager.predictionText) - \(cameraManager.confidenceScore)")
                            .font(horizontalSizeClass == .regular ? .title : .headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(horizontalSizeClass == .regular ? 20 : 12)
                    .background(
                        LinearGradient(
                            colors: [Color("ButtonColor"), Color("ButtonColor").opacity(0.45)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(15)
                    .padding(.top, 10)
                    
                    VStack(alignment: .leading) {
                        ForEach(cameraManager.allClassificationObservations, id: \.identifier) { observation in
                            Text("\(observation.identifier): \(Int(observation.confidence * 100))%")
                                .font(horizontalSizeClass == .regular ? .body : .caption)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(horizontalSizeClass == .regular ? 12 : 8)
                    .background(
                        LinearGradient(
                            colors: [Color("ButtonColor"), Color("ButtonColor").opacity(0.45)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(10)
                    .padding(.top, 5)
                    
                    // Error rate threshold / Low confidence warning
                    if let raw = cameraManager.confidenceScore.split(separator: "%").first,
                       let parsed = Float(raw) {
                        let confidence = parsed / 100.0
                        if confidence < 0.70,
                           cameraManager.predictionText != "Finding olives..." {
                            Text("Low Confidence: Aim for better lighting or focus.")
                                .font(horizontalSizeClass == .regular ? .body : .caption)
                                .foregroundColor(.yellow)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    LinearGradient(
                                        colors: [Color("ButtonColor"), Color("ButtonColor").opacity(0.45)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .padding(.top, 5)
                        }
                    }
                    
                    
                    Text(cameraManager.currentStatusMessage)
                        .font(horizontalSizeClass == .regular ? .body : .caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, horizontalSizeClass == .regular ? 20 : 10)
                        .padding(.vertical, horizontalSizeClass == .regular ? 10 : 5)
                        .background(
                            LinearGradient(
                                colors: [Color("ButtonColor"), Color("ButtonColor").opacity(0.45)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(10)
                        .padding(.bottom, 10)
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        NavigationLink(destination: HarvestRoadmapView()) {
                            Label("Roadmap", systemImage: "chart.bar.xaxis")
                                .font(horizontalSizeClass == .regular ? .title2 : .headline)
                                .foregroundColor(.white)
                                .padding(horizontalSizeClass == .regular ? 24 : 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color("ButtonColor"), Color("ButtonColor").opacity(0.45)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(15)
                        }
                        
                    }
                }
            }
            .onAppear {
                self.cameraManager.scanResultManager = self.scanResultManager
                if !cameraManager.session.isRunning {
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.cameraManager.session.startRunning()
                    }
                }
            }
            .onDisappear {
                if cameraManager.session.isRunning {
                    cameraManager.session.stopRunning()
                }
            }
            .onChange(of: scanResultManager.currentScanResult) { newResult in
                if let detail = newResult?.pestDiseaseDetail {
                    self.selectedPestDiseaseDetail = detail
                    self.showingPestDiseaseDetailSheet = true
                }
            }
            .sheet(isPresented: $showingPestDiseaseDetailSheet) {
                if let detail = selectedPestDiseaseDetail {
                    PestDiseaseDetailView(detail: detail)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

