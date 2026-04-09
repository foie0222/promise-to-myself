import SwiftUI

struct RootView: View {
    @State private var viewModel = AppViewModel()

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            switch viewModel.currentScreen {
            case .onboarding:
                OnboardingView(viewModel: viewModel)
            case .input:
                PromiseInputView(viewModel: viewModel)
            case .display:
                PromiseDisplayView(viewModel: viewModel)
            case .check:
                PromiseCheckView(viewModel: viewModel)
            case .achievement:
                AchievementView(viewModel: viewModel)
            case .acceptance:
                AcceptanceView(viewModel: viewModel)
            }
        }
        .preferredColorScheme(.dark)
    }
}
