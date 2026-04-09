import SwiftUI

struct AcceptanceView: View {
    let viewModel: AppViewModel
    @State private var showFirst = false
    @State private var showSecond = false

    var body: some View {
        VStack(spacing: 48) {
            Spacer()

            Text("約束は果たせなかった。\nそれだけのこと。")
                .font(AppTheme.messageText)
                .foregroundStyle(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
                .opacity(showFirst ? 1 : 0)

            Text("次はどんな約束を、\n自分と交わしますか？")
                .font(AppTheme.bodyText)
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .opacity(showSecond ? 1 : 0)

            Spacer()

            Text("タップして次へ")
                .font(AppTheme.captionText)
                .foregroundStyle(AppTheme.textSecondary.opacity(0.5))
                .opacity(showSecond ? 1 : 0)
                .padding(.bottom, 60)
        }
        .onTapGesture {
            viewModel.proceedToNextPromise()
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1.0).delay(0.5)) {
                showFirst = true
            }
            withAnimation(.easeIn(duration: 1.0).delay(2.0)) {
                showSecond = true
            }
        }
    }
}
