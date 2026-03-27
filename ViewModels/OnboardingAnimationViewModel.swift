import SwiftUI
import Combine

class OnboardingAnimationViewModel: ObservableObject {
    @Published var animatedTitle: String = ""
    @Published var animatedDescription: String = ""

    private var currentTitle: String = ""
    private var currentDescription: String = ""
    private var typingCancellable: AnyCancellable?

    func startTypingAnimation(for page: OnboardingPageData, duration: TimeInterval = 10.0, completion: (() -> Void)? = nil) {
        typingCancellable?.cancel()
        animatedTitle = ""
        animatedDescription = ""
        currentTitle = page.title
        currentDescription = page.description

        let titleCharacters = Array(currentTitle)
        let descriptionCharacters = Array(currentDescription)

        // Calculate delay per character for title and description
        let totalCharacters = titleCharacters.count + descriptionCharacters.count
        guard totalCharacters > 0 else {
            completion?()
            return
        }

        let delayPerCharacter = duration / Double(totalCharacters)

        var characterIndex = 0

        typingCancellable = Timer.publish(every: delayPerCharacter, on: .main, in: .common)
            .autoconnect()
            .scan(0) { count, _ in count + 1 }
            .sink { [weak self] count in
                guard let self = self else { return }

                if characterIndex < titleCharacters.count {
                    self.animatedTitle.append(titleCharacters[characterIndex])
                } else if characterIndex < totalCharacters {
                    self.animatedDescription.append(descriptionCharacters[characterIndex - titleCharacters.count])
                } else {
                    self.typingCancellable?.cancel()
                    completion?()
                }
                characterIndex += 1
            }
    }

    func resetAnimation() {
        typingCancellable?.cancel()
        animatedTitle = ""
        animatedDescription = ""
    }
}
