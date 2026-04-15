import SwiftUI

struct ShareCardView: View {
    let promiseContent: String

    var body: some View {
        ZStack {
            // Background gradient matching app theme
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.10, blue: 0.35),
                    AppTheme.background,
                    Color(red: 0.05, green: 0.03, blue: 0.12)
                ],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )

            // Subtle glow in center
            RadialGradient(
                colors: [
                    AppTheme.accent.opacity(0.15),
                    Color.clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 250
            )

            VStack(spacing: 32) {
                Spacer()

                Text("自分との約束を守り抜いた。")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.white)

                Text(promiseContent)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(AppTheme.accent)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()

                Text("自分との約束")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color(white: 0.4))
                    .padding(.bottom, 40)
            }
        }
        .frame(width: 540, height: 540)
    }

    @MainActor
    func renderImage() -> UIImage {
        let renderer = ImageRenderer(content: self)
        renderer.scale = 2
        return renderer.uiImage ?? UIImage()
    }
}
