import SwiftUI

struct ScanOptionsView: View {
    @State private var isShowingLiveScan = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @EnvironmentObject var scanResultManager: ScanResultManager

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("Background")
                    .ignoresSafeArea()

                VStack(spacing: 30) {
                    Spacer()

                    // Main Scan Card
                    VStack(spacing: 22) {

                        Image(systemName: "camera.fill")
                            .font(.system(size: horizontalSizeClass == .regular ? 100 : 70, weight: .semibold))
                            .foregroundColor(Color("Background"))

                        Text("Scan Olives")
                            .font(.system(size: horizontalSizeClass == .regular ? 40 : 30, weight: .bold))
                            .foregroundColor(Color("Background"))

                        Text("Start a real-time analysis using your camera")
                            .font(.system(size: horizontalSizeClass == .regular ? 20 : 16))
                            .foregroundColor(Color("Background").opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)

                        Button {
                            isShowingLiveScan = true
                        } label: {
                            Text("Start Live Scan")
                                .font(horizontalSizeClass == .regular ? .title2 : .headline)
                                .foregroundColor(Color("Background"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [Color("ButtonColor"), Color("ButtonColor").opacity(0.45)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(18)
                                .shadow(radius: 6)
                        }
                        .padding(.horizontal, 20)
                    }
                    .frame(width: min(geometry.size.width * 0.85, horizontalSizeClass == .regular ? 500 : 300))
                    .frame(height: min(geometry.size.height * 0.6, horizontalSizeClass == .regular ? 600 : 420))
                    .background(
                        LinearGradient(
                            colors: [Color("ButtonColor"), Color("ButtonColor").opacity(0.45)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(30)
                    .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 10)

                    Spacer()

                    Text("Tip: Use natural light for best results")
                        .font(horizontalSizeClass == .regular ? .body : .caption)
                        .foregroundColor(Color("ButtonColor").opacity(0.9))
                        .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Scan Olives")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $isShowingLiveScan) {
            LiveScanView()
        }
    }
}

struct ScanOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        ScanOptionsView()
            .environmentObject(ScanResultManager()) // Provide environment object for preview
    }
}
