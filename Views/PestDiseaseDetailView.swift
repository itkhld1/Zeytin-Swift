import SwiftUI

struct PestDiseaseDetailView: View {
    let detail: PestDiseaseDetail
    @Environment(\.dismiss) var dismiss
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()

            VStack(spacing: 0) {

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 26) {
                        Spacer(minLength: 20)

                        VStack(spacing: 26) {

                            Image(systemName: "ladybug.fill")
                                .font(.system(size: horizontalSizeClass == .regular ? 120 : 80, weight: .semibold))
                                .foregroundColor(Color("Background"))

                            Text(detail.name)
                                .font(.system(size: horizontalSizeClass == .regular ? 42 : 28, weight: .bold))
                                .foregroundColor(Color("Background"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                            infoBlock(
                                title: "Description",
                                text: detail.description
                            )

                            infoBlock(
                                title: "Symptoms",
                                text: detail.symptoms
                            )

                            infoBlock(
                                title: "Mitigation",
                                text: detail.mitigation
                            )

                            if let url = detail.learnMoreURL {
                                Link(destination: url) {
                                    Text("Learn More")
                                        .font(horizontalSizeClass == .regular ? .title2 : .headline)
                                        .foregroundColor(Color("ButtonColor"))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(Color("Background"))
                                        .cornerRadius(16)
                                }
                            }

                        }
                        .padding(horizontalSizeClass == .regular ? 45 : 30)
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
                        .cornerRadius(30)
                        .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 10)
                        .frame(maxWidth: horizontalSizeClass == .regular ? 600 : 340)

                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                }

                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(horizontalSizeClass == .regular ? .title2 : .headline)
                        .foregroundColor(Color("Background"))
                        .frame(maxWidth: horizontalSizeClass == .regular ? 400 : .infinity)
                        .padding(.vertical, 16)
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
                        .cornerRadius(18)
                        .shadow(radius: 5)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                }
            }
        }
        .navigationBarHidden(true)
    }

    private func infoBlock(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(horizontalSizeClass == .regular ? .title3 : .headline)
                .foregroundColor(Color("Background"))

            Text(text)
                .font(.system(size: horizontalSizeClass == .regular ? 18 : 15))
                .foregroundColor(Color("Background"))
                .opacity(0.9)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
