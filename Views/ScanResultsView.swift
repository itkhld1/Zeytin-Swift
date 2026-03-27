import SwiftUI

struct ScanResultsView: View {
    @EnvironmentObject var scanResultManager: ScanResultManager
    @State private var showingPestDiseaseDetailSheet = false
    @State private var selectedPestDiseaseDetail: PestDiseaseDetail?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {

                    if let result = scanResultManager.currentScanResult {

                        // MARK: Image Card
                        if let uiImage = result.uiImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: horizontalSizeClass == .regular ? 500 : 300, height: horizontalSizeClass == .regular ? 350 : 220)
                                .clipped()
                                .cornerRadius(24)
                                .shadow(color: .black.opacity(0.35), radius: 18, x: 0, y: 10)
                        }

                        // MARK: Status Card
                        VStack(spacing: 16) {

                            Text(result.status.uppercased())
                                .font(.system(size: horizontalSizeClass == .regular ? 36 : 26, weight: .bold))
                                .foregroundColor(Color("Background"))

                            Text("Confidence: \(result.confidence)")
                                .font(horizontalSizeClass == .regular ? .title3 : .subheadline)
                                .foregroundColor(Color("Background").opacity(0.85))

                            Text(result.description)
                                .font(.system(size: horizontalSizeClass == .regular ? 20 : 16))
                                .foregroundColor(Color("Background"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 18)

                            tipView(for: result.status)

                        }
                        .cardStyle()

                        // MARK: Pest / Disease Detail
                        if (result.status == "Pest" || result.status == "Disease"),
                           let detail = result.pestDiseaseDetail {

                            Button {
                                selectedPestDiseaseDetail = detail
                                showingPestDiseaseDetailSheet = true
                            } label: {
                                GradientInfoCard(
                                    title: detail.name,
                                    description: "Tap to learn symptoms & treatments",
                                    icon: "ladybug.fill"
                                )
                            }
                            .frame(maxWidth: horizontalSizeClass == .regular ? 600 : .infinity)
                        }

                        // MARK: Action Buttons
                        HStack(spacing: 16) {

                            GradientActionButton(
                                title: "Share",
                                icon: "square.and.arrow.up"
                            ) {
                                print("Share tapped")
                            }

                            GradientActionButton(
                                title: "Feedback",
                                icon: "bubble.left.and.bubble.right"
                            ) {
                                print("Feedback tapped")
                            }
                        }
                        .padding(.horizontal, 20)
                        .frame(maxWidth: horizontalSizeClass == .regular ? 600 : .infinity)

                    } else {
                        emptyState
                    }
                }
                .padding(.vertical, 30)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Scan Results")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPestDiseaseDetailSheet) {
            if let detail = selectedPestDiseaseDetail {
                PestDiseaseDetailView(detail: detail)
            }
        }
    }

    // MARK: Tip Builder
    @ViewBuilder
    private func tipView(for status: String) -> some View {
        switch status {
        case "Green":
            GradientTipCard(
                text: "Early harvest — perfect for peppery oil or brining.",
                icon: "leaf.fill"
            )
        case "Veraison":
            GradientTipCard(
                text: "Balanced flavor — ideal harvest window.",
                icon: "paintpalette.fill"
            )
        case "Black":
            GradientTipCard(
                text: "Rich & mellow — great for table olives.",
                icon: "circle.fill"
            )
        default:
            EmptyView()
        }
    }

    // MARK: Empty State
    private var emptyState: some View {
        VStack(spacing: 18) {
            Image(systemName: "photo.fill")
                .font(.system(size: horizontalSizeClass == .regular ? 100 : 60))
                .foregroundColor(Color("ButtonColor"))

            Text("No scan result yet")
                .font(horizontalSizeClass == .regular ? .title : .headline)
                .foregroundColor(Color("Background"))

            Text("Perform a live scan or photo scan to see results here.")
                .font(horizontalSizeClass == .regular ? .title3 : .subheadline)
                .foregroundColor(Color("Background").opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(width: horizontalSizeClass == .regular ? 500 : 300, height: horizontalSizeClass == .regular ? 500 : 300)
        .background(
            LinearGradient(
                colors: [Color("ButtonColor"), Color("ButtonColor").opacity(0.45)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(30)
        .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 10)
    }
}

struct GradientTipCard: View {
    let text: String
    let icon: String
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(horizontalSizeClass == .regular ? .title : .title2)
                .foregroundColor(Color("Background"))

            Text(text)
                .font(horizontalSizeClass == .regular ? .title3 : .subheadline)
                .foregroundColor(Color("Background"))

            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color("ButtonColor"), Color("ButtonColor").opacity(0.45)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(18)
        .shadow(radius: 6)
        .padding(.horizontal, 20)
    }
}

struct GradientActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(horizontalSizeClass == .regular ? .title2 : .headline)
                .foregroundColor(Color("Background"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, horizontalSizeClass == .regular ? 20 : 14)
                .background(
                    LinearGradient(
                        colors: [Color("ButtonColor"), Color("ButtonColor").opacity(0.45)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(radius: 6)
        }
    }
}

struct ScanResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ScanResultsView()
            .environmentObject(ScanResultManager())
    }
}
