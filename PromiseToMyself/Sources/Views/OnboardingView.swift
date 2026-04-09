import SwiftUI

struct OnboardingView: View {
    let viewModel: AppViewModel

    var body: some View {
        VStack(spacing: 40) {
            Spacer()

            Text("自分との約束")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(AppTheme.textPrimary)

            VStack(spacing: 16) {
                Text("たった一つの約束を、自分と交わす。")
                    .font(AppTheme.bodyText)
                    .foregroundStyle(AppTheme.textSecondary)

                Text("それだけのアプリです。")
                    .font(AppTheme.bodyText)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .multilineTextAlignment(.center)

            Spacer()

            Button {
                Task {
                    await NotificationService.requestPermission()
                    viewModel.completeOnboarding()
                }
            } label: {
                Text("はじめる")
                    .font(AppTheme.buttonText)
                    .foregroundStyle(AppTheme.background)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
        }
    }
}
