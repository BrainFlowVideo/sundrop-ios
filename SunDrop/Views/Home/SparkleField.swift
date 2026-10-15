import SwiftUI

/// Floating four-point sparkles that drift upward and twinkle.
struct SparkleField: View {
    var count: Int = 14
    var tint: Color = .raspberryRed

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                for i in 0..<count {
                    let seed = Double(i) * 12.9898
                    let speed = 0.04 + (sin(seed) * 0.5 + 0.5) * 0.05
                    let phase = (t * speed + Double(i) / Double(count))
                        .truncatingRemainder(dividingBy: 1)
                    let x = (sin(seed * 3.1) * 0.5 + 0.5) * size.width + sin(t * 0.8 + seed) * 10
                    let y = size.height * (1 - phase)
                    let radius = 4 + 5 * (cos(seed) * 0.5 + 0.5)
                    let alpha = sin(phase * .pi) * 0.65
                    let star = Self.starPath(center: CGPoint(x: x, y: y), radius: radius)
                    context.fill(star, with: .color(tint.opacity(alpha)))
                }
            }
        }
        .accessibilityHidden(true)
    }

    private static func starPath(center: CGPoint, radius: Double) -> Path {
        var p = Path()
        let inner = radius * 0.25
        for i in 0..<8 {
            let angle = Double(i) * .pi / 4 - .pi / 2
            let r = i.isMultiple(of: 2) ? radius : inner
            let pt = CGPoint(x: center.x + cos(angle) * r, y: center.y + sin(angle) * r)
            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
        }
        p.closeSubpath()
        return p
    }
}
