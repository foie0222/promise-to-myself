import SwiftUI

struct AchievementView: View {
    let viewModel: AppViewModel
    @State private var animate = false
    @State private var showShareButton = false
    @State private var shareImage: UIImage?

    private var promiseContent: String {
        viewModel.currentPromise?.content ?? ""
    }

    var body: some View {
        ZStack {
            CosmicParticleEffect()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Text("自分との約束を守り抜いた。")
                    .font(AppTheme.heroText)
                    .foregroundStyle(AppTheme.textPrimary)
                    .opacity(animate ? 1 : 0)
                    .scaleEffect(animate ? 1 : 0.8)

                Text("新しい自分が、ここにいる。")
                    .font(AppTheme.bodyText)
                    .foregroundStyle(AppTheme.accent)
                    .opacity(animate ? 1 : 0)

                Spacer()

                // Share button
                if showShareButton, let image = shareImage {
                    ShareLink(
                        item: Image(uiImage: image),
                        preview: SharePreview("自分との約束を果たした", image: Image(uiImage: image))
                    ) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.and.arrow.up")
                            Text("シェアする")
                        }
                        .font(AppTheme.buttonText)
                        .foregroundStyle(AppTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppTheme.accent.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppTheme.accent.opacity(0.5), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 40)
                    .transition(.opacity)
                }

                Button {
                    viewModel.proceedToNextPromise()
                } label: {
                    Text("次の約束へ")
                        .font(AppTheme.captionText)
                        .foregroundStyle(AppTheme.textSecondary.opacity(0.5))
                }
                .opacity(showShareButton ? 1 : 0)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5).delay(0.5)) {
                animate = true
            }
            // Pre-render share image
            shareImage = ShareCardView(promiseContent: promiseContent).renderImage()

            withAnimation(.easeIn(duration: 0.8).delay(2.5)) {
                showShareButton = true
            }
        }
    }
}
