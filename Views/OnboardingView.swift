import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @State private var currentPage = 0
    @StateObject private var animationViewModel = OnboardingAnimationViewModel()
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    let onboardingPages: [OnboardingPageData] = [
        OnboardingPageData(
            imageName: "leaf.fill",
            title: "From the Heart of Denizli",
            description: "**Türkiye has become the world’s 2nd largest olive oil producer**, and our home, **Denizli**, is a vital part of this ***liquid gold*** legacy with over **2.9 million** olive trees. But behind every bottle and breakfast jar is a struggle to preserve this ancient craft."
        ),
        OnboardingPageData(
            imageName: "chart.bar.xaxis",
            title: "Knowledge is Yield",
            description: "Every year, up to ***30% of Mediterranean olive crops are destroyed*** by pests like the Olive Fruit Fly. In oil production, poor harvesting timing can cause an **80%** drop in total value. Traditional habits like ***stick beating*** often damage the fruit, causing 12 times more harm than careful hand-picking."
        ),
        OnboardingPageData(
            imageName: "fork.knife",
            title: "Breakfast or Oil?",
            description: "Not all olives are born equal. Many local makers in **Denizli** struggle to distinguish between varieties: **table olives (for breakfast) require a high flesh-to-pit ratio, while oil olives need a high oil content—up to 30% by weight**. Picking at the wrong time ruins the crunch for your breakfast and the quality of your oil."
        ),
        OnboardingPageData(
            imageName: "viewfinder",
            title: "Precision in Your Pocket",
            description: "***Zeytin*** uses real-time analysis to identify exactly when your harvest is ready. Whether you're a small-scale farmer or a homemade maker, we ensure your olives reach their peak potential—minimizing waste and maximizing quality for every meal."
        )
    ]

    var body: some View {
        ZStack {
            Color("Background")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(0..<onboardingPages.count, id: \.self) { index in
                        OnboardingPageView(page: onboardingPages[index])
                            .tag(index)
                            .environmentObject(animationViewModel)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .animation(.easeInOut, value: currentPage)
                .onAppear {
                    animationViewModel.startTypingAnimation(for: onboardingPages[currentPage])
                }
                .onChange(of: currentPage) { newPageIndex in
                    animationViewModel.resetAnimation()
                    animationViewModel.startTypingAnimation(for: onboardingPages[newPageIndex])
                }


                Spacer(minLength: 10)

                Button(action: nextTapped) {
                    Text(currentPage == onboardingPages.count - 1 ? "Get Started" : "Next")
                        .font(horizontalSizeClass == .regular ? .title2 : .headline)
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
                        .padding(.bottom, 40)
                }
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }

    private func nextTapped() {
        if currentPage < onboardingPages.count - 1 {
            withAnimation {
                currentPage += 1
            }
        } else {
            hasCompletedOnboarding = true
        }
    }
    
    struct OnboardingPageView: View {
        let page: OnboardingPageData
        @EnvironmentObject var animationViewModel: OnboardingAnimationViewModel
        @Environment(\.horizontalSizeClass) var horizontalSizeClass

        var body: some View {
            GeometryReader { geometry in
                let cardWidth = min(geometry.size.width * 0.85, horizontalSizeClass == .regular ? 600 : 400)
                let cardHeight = min(geometry.size.height * 0.7, horizontalSizeClass == .regular ? 700 : 450)
                
                VStack(spacing: 20) {
                    Spacer()

                    Image(systemName: page.imageName)
                        .font(.system(size: horizontalSizeClass == .regular ? 120 : 80, weight: .semibold))
                        .foregroundColor(Color("Background"))

                    Text(animationViewModel.animatedTitle)
                        .font(.system(size: horizontalSizeClass == .regular ? 42 : 30, weight: .bold))
                        .foregroundColor(Color("Background"))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .padding(.horizontal, 20)

                    Text(try! AttributedString(markdown:animationViewModel.animatedDescription))
                        .font(.system(size: horizontalSizeClass == .regular ? 20 : 16))
                        .foregroundColor(Color("Background"))
                        .multilineTextAlignment(.center)
                        .lineLimit(16)
                        .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .frame(width: cardWidth, height: cardHeight)
                .background(LinearGradient(
                    colors: [Color("ButtonColor"), Color("ButtonColor").opacity(0.45)],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .cornerRadius(30)
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
    }
}

struct OnboardingPageData: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
