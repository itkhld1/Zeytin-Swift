import SwiftUI

struct AboutTechView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    let techFeatures = [
        ("Credits", "c.circle", "The photos used for training the OliveClassifier model were downloaded for free from Pinterest and Pexels. These platforms offer a wide range of images that are available for use without specific licensing requirements, making them ideal resources for educational and development purposes."),
        ("Core ML", "brain.head.profile", "Leverages a custom-trained machine learning model (OliveClassifier) for efficient, on-device classification of olive ripeness and health issues."),
        ("Vision Framework", "eye.fill", "Utilizes Apple's Vision framework to process live camera frames, detect relevant objects, and extract features for real-time inference."),
        ("Color Analysis", "camera.filters", "Analyzes color distribution within olives to refine ripeness predictions and provide visual feedback."),
        ("Haptic Feedback", "sensor", "Provides subtle physical feedback for key interactions, improving user experience."),
    ]

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            VStack {

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 26) {

                        Spacer(minLength: 20)

                        VStack(spacing: 20) {
                            Image(systemName: "cpu.fill")
                                .font(.system(size: horizontalSizeClass == .regular ? 100 : 70, weight: .semibold))
                                .foregroundColor(Color("ButtonColor"))

                            Text("How the App Works")
                                .font(.system(size: horizontalSizeClass == .regular ? 42 : 30, weight: .bold))
                                .foregroundColor(Color("ButtonColor"))
                                .multilineTextAlignment(.center)

                            Text("WWDC26 • Ahmad Khaled Samim")
                                .font(horizontalSizeClass == .regular ? .title3 : .subheadline)
                                .foregroundColor(Color("ButtonColor").opacity(0.9))
                        }

                        VStack(spacing: 20) {
                            ForEach(techFeatures, id: \.0) { feature in
                                techCard(
                                    title: feature.0,
                                    icon: feature.1,
                                    description: feature.2
                                )
                            }
                        }
                        .frame(maxWidth: horizontalSizeClass == .regular ? 700 : .infinity)

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func techCard(title: String, icon: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: horizontalSizeClass == .regular ? 44 : 34, weight: .semibold))
                    .foregroundColor(Color("Background"))

                Text(title)
                    .font(horizontalSizeClass == .regular ? .title2 : .headline)
                    .foregroundColor(Color("Background"))
            }

            Text(description)
                .font(.system(size: horizontalSizeClass == .regular ? 18 : 15))
                .foregroundColor(Color("Background").opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)

        }
        .padding(horizontalSizeClass == .regular ? 32 : 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color("ButtonColor"),
                    Color("ButtonColor").opacity(0.45)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(26)
        .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 10)
    }
}

struct AboutTechView_Previews: PreviewProvider {
    static var previews: some View {
        AboutTechView()
    }
}
