import SwiftUI

struct CosmicParticleEffect: View {
    @State private var particles: [Particle] = []
    @State private var startTime: Date = .now

    private let particleCount = 150

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startTime)

            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)

                for particle in particles {
                    let progress = min(elapsed / particle.duration, 1.0)
                    let easedProgress = easeOutCubic(progress)

                    let currentX = center.x + particle.direction.x * particle.distance * easedProgress
                    let currentY = center.y + particle.direction.y * particle.distance * easedProgress

                    let alpha = alphaForProgress(progress)
                    let size = particle.size * (0.5 + easedProgress * 0.5)

                    let color = particle.color.opacity(alpha)
                    let rect = CGRect(
                        x: currentX - size / 2,
                        y: currentY - size / 2,
                        width: size,
                        height: size
                    )

                    context.fill(
                        Circle().path(in: rect),
                        with: .color(color)
                    )

                    if particle.size > 3 {
                        let glowRect = CGRect(
                            x: currentX - size,
                            y: currentY - size,
                            width: size * 2,
                            height: size * 2
                        )
                        context.fill(
                            Circle().path(in: glowRect),
                            with: .color(color.opacity(alpha * 0.3))
                        )
                    }
                }
            }
        }
        .onAppear {
            particles = (0..<particleCount).map { _ in
                Particle.random()
            }
            startTime = .now
        }
    }

    private func easeOutCubic(_ t: Double) -> Double {
        1 - pow(1 - t, 3)
    }

    private func alphaForProgress(_ progress: Double) -> Double {
        if progress < 0.1 {
            return progress / 0.1
        } else if progress > 0.7 {
            return max(0, 1 - (progress - 0.7) / 0.3)
        }
        return 1.0
    }
}

private struct Particle {
    let direction: CGPoint
    let distance: CGFloat
    let duration: TimeInterval
    let size: CGFloat
    let color: Color

    static func random() -> Particle {
        let angle = Double.random(in: 0...(2 * .pi))
        let colors: [Color] = [
            Color(red: 0.75, green: 0.63, blue: 1.0),
            Color(red: 0.5, green: 0.5, blue: 1.0),
            Color.white,
            Color(red: 0.6, green: 0.8, blue: 1.0),
            Color(red: 1.0, green: 0.8, blue: 0.9),
        ]

        return Particle(
            direction: CGPoint(x: cos(angle), y: sin(angle)),
            distance: CGFloat.random(in: 100...500),
            duration: TimeInterval.random(in: 2.0...4.0),
            size: CGFloat.random(in: 1...6),
            color: colors.randomElement()!
        )
    }
}
