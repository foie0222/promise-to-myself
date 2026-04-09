import SwiftUI

struct CancelConfirmationView: View {
    let viewModel: AppViewModel
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 20) {
                Text("言葉は命です。")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("あなたが自分に誓った言葉を、\n本当に手放しますか？")
                    .font(AppTheme.bodyText)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            VStack(spacing: 16) {
                Button {
                    isPresented = false
                } label: {
                    Text("約束を続ける")
                        .font(AppTheme.buttonText)
                        .foregroundStyle(AppTheme.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button {
                    isPresented = false
                    viewModel.cancelPromise()
                } label: {
                    Text("それでも取り消す")
                        .font(AppTheme.captionText)
                        .foregroundStyle(AppTheme.textSecondary.opacity(0.5))
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 60)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.background)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
