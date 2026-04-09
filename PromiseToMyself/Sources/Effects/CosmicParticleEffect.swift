import SwiftUI

struct CosmicParticleEffect: View {
    @State private var particles: [Particle] = []
    @State private var startTime: Date = .now

    private let particleCount = 150

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startTime)

            Canvas { context, canvasSize in
                let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)

                for particle in particles {
                    let progress = min(elapsed / particle.duration, 1.0)
                    let easedProgress = easeOutCubic(progress)
                    let alpha = alphaForProgress(progress)
                    let particleSize = particle.size * (0.5 + easedProgress * 0.5)

                    let x = center.x + particle.direction.x * particle.distance * easedProgress
                    let y = center.y + particle.direction.y * particle.distance * easedProgress

                    let rect = CGRect(
                        x: x - particleSize / 2,
                        y: y - particleSize / 2,
                        width: particleSize,
                        height: particleSize
                    )
                    context.fill(Circle().path(in: rect), with: .color(particle.color.opacity(alpha)))

                    if particle.size > 3 {
                        let glowRect = CGRect(
                            x: x - particleSize, y: y - particleSize,
                            width: particleSize * 2, height: particleSize * 2
                        )
                        context.fill(Circle().path(in: glowRect), with: .color(particle.color.opacity(alpha * 0.3)))
                    }
                }
            }
        }
        .onAppear {
            particles = (0..<particleCount).map { _ in Particle.random() }
            startTime = .now
        }
    }

    private func easeOutCubic(_ t: Double) -> Double {
        1 - pow(1 - t, 3)
    }

    private func alphaForProgress(_ progress: Double) -> Double {
        if progress < 0.1 { return progress / 0.1 }
        if progress > 0.7 { return max(0, 1 - (progress - 0.7) / 0.3) }
        return 1.0
    }
}

private struct Particle {
    let direction: CGPoint
    let distance: CGFloat
    let duration: TimeInterval
    let size: CGFloat
    let color: Color

    private static let colors: [Color] = [
        AppTheme.accent,
        AppTheme.accentBlue,
        .white,
        Color(red: 0.6, green: 0.8, blue: 1.0),
        Color(red: 1.0, green: 0.8, blue: 0.9),
    ]

    static func random() -> Particle {
        let angle = Double.random(in: 0...(2 * .pi))
        return Particle(
            direction: CGPoint(x: cos(angle), y: sin(angle)),
            distance: .random(in: 100...500),
            duration: .random(in: 2.0...4.0),
            size: .random(in: 1...6),
            color: colors.randomElement()!
        )
    }
}
