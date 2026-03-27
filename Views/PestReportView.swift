import SwiftUI

struct PestReportView: View {
    let pestAlerts: [ScanResult]
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        NavigationStack {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 26) {

                        Spacer(minLength: 20)

                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "ladybug.fill")
                                .font(.system(size: horizontalSizeClass == .regular ? 90 : 60, weight: .semibold))
                                .foregroundColor(Color("Background"))

                            Text("Pest & Disease Alerts")
                                .font(.system(size: horizontalSizeClass == .regular ? 40 : 28, weight: .bold))
                                .foregroundColor(Color("Background"))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 20)

                        // Alert Cards
                        VStack(spacing: 18) {
                            ForEach(pestAlerts) { result in
                                NavigationLink {
                                    PestDiseaseDetailView(
                                        detail: result.pestDiseaseDetail!
                                    )
                                } label: {
                                    pestAlertCard(result: result)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        .frame(maxWidth: horizontalSizeClass == .regular ? 600 : .infinity)

                        Spacer(minLength: 40)
                    }
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color("ButtonColor"))
                    .font(horizontalSizeClass == .regular ? .title3 : .body)
                }
            }
        }
    }

    private func pestAlertCard(result: ScanResult) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.25))
                    .frame(width: horizontalSizeClass == .regular ? 80 : 60, height: horizontalSizeClass == .regular ? 80 : 60)
                Image(systemName: "ladybug.fill")
                    .font(horizontalSizeClass == .regular ? .title : .title2)
                    .foregroundColor(.red)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(result.pestDiseaseDetail?.name ?? "Unknown Pest/Disease")
                    .font(horizontalSizeClass == .regular ? .title3 : .headline)
                    .foregroundColor(Color("Background"))

                Text("Confidence: \(result.confidence)")
                    .font(horizontalSizeClass == .regular ? .body : .subheadline)
                    .foregroundColor(Color("Background").opacity(0.8))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(horizontalSizeClass == .regular ? .title2 : .body)
                .foregroundColor(Color("Background").opacity(0.6))
        }
        .padding(horizontalSizeClass == .regular ? 20 : 16)
        .background(
            LinearGradient(
                colors: [
                    Color("ButtonColor"),
                    Color("ButtonColor").opacity(0.45)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .cornerRadius(22)
            .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 8)
        )
    }
}
