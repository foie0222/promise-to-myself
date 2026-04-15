import SwiftUI

struct PromiseDisplayView: View {
    let viewModel: AppViewModel
    @State private var showCancelConfirmation = false

    private var promise: Promise? { viewModel.currentPromise }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            if let promise {
                Text(promise.content)
                    .font(AppTheme.promiseText)
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                VStack(spacing: 8) {
                    Text("あと \(promise.daysRemaining) 日")
                        .font(AppTheme.countdownText)
                        .foregroundStyle(AppTheme.accent)

                    Text(promise.deadline, style: .date)
                        .font(AppTheme.captionText)
                        .foregroundStyle(AppTheme.textSecondary)
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                }
            }

            Spacer()

            Button {
                showCancelConfirmation = true
            } label: {
                Text("約束を取り消す")
                    .font(AppTheme.captionText)
                    .foregroundStyle(AppTheme.textSecondary.opacity(0.5))
            }
            .padding(.bottom, 40)
        }
        .sheet(isPresented: $showCancelConfirmation) {
            CancelConfirmationView(
                viewModel: viewModel,
                isPresented: $showCancelConfirmation
            )
        }
    }
}
