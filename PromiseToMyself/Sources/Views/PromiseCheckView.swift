import SwiftUI

struct PromiseCheckView: View {
    let viewModel: AppViewModel

    var body: some View {
        VStack(spacing: 48) {
            Spacer()

            VStack(spacing: 16) {
                Text("自分との約束、")
                    .font(AppTheme.titleText)
                    .foregroundStyle(AppTheme.textSecondary)

                Text("守れましたか？")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)
            }

            if let promise = viewModel.currentPromise {
                Text(promise.content)
                    .font(AppTheme.bodyText)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            VStack(spacing: 16) {
                Button {
                    viewModel.answerKept(yes: true)
                } label: {
                    Text("はい")
                        .font(AppTheme.buttonText)
                        .foregroundStyle(AppTheme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    viewModel.answerKept(yes: false)
                } label: {
                    Text("いいえ")
                        .font(AppTheme.buttonText)
                        .foregroundStyle(AppTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.textSecondary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
        }
    }
}
