import SwiftUI

struct WelcomeView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("Background")
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    VStack(spacing: 10) {
                        Image("logo1")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: geometry.size.height * 0.3)
                            .padding(.bottom, geometry.size.height * 0.05)

                        Text("Zeytin")
                            .font(.system(size: horizontalSizeClass == .regular ? 48 : 30, weight: .bold))
                            .foregroundColor(Color("Background"))
                            .multilineTextAlignment(.center)

                        Text("Smart Harvest")
                            .font(.system(size: horizontalSizeClass == .regular ? 24 : 16, weight: .semibold))
                            .foregroundColor(Color("Background"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .frame(maxWidth: horizontalSizeClass == .regular ? 500 : 300)
                    .frame(height: geometry.size.height * 0.55)
                    .background(
                        LinearGradient(
                            colors: [Color("ButtonColor"), Color("ButtonColor").opacity(0.45)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(30)
                    .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 10)
                    .padding(.horizontal, 30)

                    Spacer()

                    NavigationLink(destination: MainTabView()) {
                        Text("Start Analysis")
                            .font(horizontalSizeClass == .regular ? .title : .headline)
                            .foregroundColor(Color("Background"))
                            .frame(maxWidth: horizontalSizeClass == .regular ? 400 : .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color("ButtonColor"), Color("ButtonColor").opacity(0.45)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(18)
                            .shadow(radius: 5)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                    }

                    Text("Designed in Denizli · 100% Offline")
                        .font(horizontalSizeClass == .regular ? .body : .caption)
                        .foregroundColor(Color("ButtonColor").opacity(0.8))
                        .padding(.bottom, 45)
                }
                .ignoresSafeArea(.container, edges: .bottom)
                .frame(maxWidth: .infinity)
            }
        }
    }
}
