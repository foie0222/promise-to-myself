import SwiftUI

struct AchievementView: View {
    let viewModel: AppViewModel
    @State private var animate = false

    var body: some View {
        ZStack {
            // TODO: Replace with CosmicParticleEffect() in Task 9
            Color.clear.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Text("約束を、果たした。")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .opacity(animate ? 1 : 0)
                    .scaleEffect(animate ? 1 : 0.8)

                Text("新しい自分が、ここにいる。")
                    .font(AppTheme.bodyText)
                    .foregroundStyle(AppTheme.accent)
                    .opacity(animate ? 1 : 0)

                Spacer()

                Text("タップして次へ")
                    .font(AppTheme.captionText)
                    .foregroundStyle(AppTheme.textSecondary.opacity(0.5))
                    .opacity(animate ? 1 : 0)
                    .padding(.bottom, 60)
            }
        }
        .onTapGesture {
            viewModel.proceedToNextPromise()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5).delay(0.5)) {
                animate = true
            }
        }
    }
}
