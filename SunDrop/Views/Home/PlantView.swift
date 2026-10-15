import SwiftUI

/// A potted plant that grows every time a SunDrop is added to the jar.
///
/// - 0 drops: a seed resting in the soil
/// - 1–2: a tiny sprout
/// - 3–8: leaves pop out, one at a time
/// - 9: the stem reaches full height
/// - 10: a flower bud forms
/// - 11: the sunflower starts to open
/// - 12+: a full sunflower in bloom
struct PlantView: View {
    /// Number of SunDrops in the jar.
    let count: Int
    /// Bump this number to make the plant hop (used when it is tapped).
    var hopTrigger: Int = 0

    static let bloomAt = 12

    @State private var sway = false

    private let stemColor = Color(hex: 0x4F9D5D)

    private var n: Int { max(0, count) }
    private var stemHeight: CGFloat { n == 0 ? 0 : min(8 + CGFloat(n) * 5, 58) }
    private var leafCount: Int { n < 3 ? 0 : min(n - 2, 6) }
    /// 0 = closed bud, 0.55 = opening, 1 = full bloom
    private var openness: CGFloat { n >= Self.bloomAt ? 1 : (n == Self.bloomAt - 1 ? 0.55 : 0) }
    private var headY: CGFloat { 94 - stemHeight }

    var body: some View {
        ZStack {
            plant
                .rotationEffect(.degrees(sway ? 3 : -3), anchor: UnitPoint(x: 0.5, y: 94.0 / 130.0))
            pot
        }
        .frame(width: 80, height: 130)
        .animation(.spring(response: 0.7, dampingFraction: 0.6), value: n)
        .keyframeAnimator(initialValue: PlantHop(), trigger: hopTrigger) { content, value in
            content
                .scaleEffect(x: value.sx, y: value.sy, anchor: .bottom)
                .offset(y: value.y)
        } keyframes: { _ in
            KeyframeTrack(\.y) {
                SpringKeyframe(-14, duration: 0.18, spring: .bouncy)
                SpringKeyframe(0, duration: 0.4, spring: .bouncy)
            }
            KeyframeTrack(\.sx) {
                SpringKeyframe(0.95, duration: 0.18, spring: .bouncy)
                SpringKeyframe(1.0, duration: 0.4, spring: .bouncy)
            }
            KeyframeTrack(\.sy) {
                SpringKeyframe(1.08, duration: 0.18, spring: .bouncy)
                SpringKeyframe(1.0, duration: 0.4, spring: .bouncy)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) { sway = true }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(stageDescription)
    }

    private var stageDescription: String {
        switch n {
        case 0: "A seed resting in the pot. Add a SunDrop to wake it up."
        case 1...2: "A tiny sprout is growing."
        case 3...9: "A leafy plant with \(leafCount) leaves."
        case 10: "A flower bud is forming."
        case 11: "The sunflower is starting to open."
        default: "A sunflower in full bloom!"
        }
    }

    // MARK: Plant (80 x 130 space; soil line at y = 94)

    private var plant: some View {
        ZStack {
            // Stem
            Capsule()
                .fill(stemColor)
                .frame(width: 5, height: stemHeight + 4)
                .position(x: 40, y: 94 - stemHeight / 2 + 2)

            // Leaves
            ForEach(0..<leafCount, id: \.self) { i in
                let left = i.isMultiple(of: 2)
                let offset = min(CGFloat(10 + i * 6), stemHeight - 4)
                PlantLeaf()
                    .frame(width: 22, height: 11)
                    .rotationEffect(.degrees(left ? -28 : 28))
                    .position(x: left ? 27 : 53, y: 94 - offset)
                    .transition(.scale(scale: 0.1).combined(with: .opacity))
            }

            // Bud and sunflower
            if n >= Self.bloomAt - 2 {
                head
                    .position(x: 40, y: headY)
                    .transition(.scale(scale: 0.3).combined(with: .opacity))
            }
        }
        .frame(width: 80, height: 130)
    }

    private var head: some View {
        ZStack {
            if openness > 0 {
                ForEach(0..<12, id: \.self) { k in
                    Ellipse()
                        .fill(LinearGradient(
                            colors: [Color(hex: 0xFFD66B), Color(hex: 0xFFB02E)],
                            startPoint: .top, endPoint: .bottom))
                        .frame(width: 10.4, height: 20)
                        .offset(y: -17)
                        .rotationEffect(.degrees(Double(k) * 30))
                }
                .scaleEffect(openness)
                Circle()
                    .fill(RadialGradient(
                        colors: [Color(hex: 0x8A5A3C), Color(hex: 0x4E2E1E)],
                        center: UnitPoint(x: 0.4, y: 0.35), startRadius: 0, endRadius: 14))
                    .frame(width: 22, height: 22)
                if openness == 1 {
                    ForEach(Array([(-4.0, -3.0), (4, -3), (0, 1), (-5, 4), (5, 4)].enumerated()), id: \.offset) { _, p in
                        Circle().fill(Color(hex: 0x5A3322).opacity(0.75))
                            .frame(width: 2.4, height: 2.4)
                            .offset(x: p.0, y: p.1)
                    }
                }
            } else {
                // Closed bud
                Circle().fill(stemColor).frame(width: 18, height: 18)
                Capsule().fill(Color.sunflowerGold).frame(width: 12, height: 6).offset(y: -6)
            }
        }
    }

    // MARK: Pot

    private var pot: some View {
        ZStack {
            PotShape().fill(Color.raspberryRed)
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color(hex: 0xE8366F))
                .frame(width: 64, height: 12)
                .position(x: 40, y: 94)
            // Soil
            Ellipse().fill(Color(hex: 0x6B4632)).frame(width: 54, height: 9).position(x: 40, y: 89.5)
            if n == 0 {
                Ellipse().fill(Color(hex: 0x8A5E44)).frame(width: 16, height: 8).position(x: 40, y: 87)
            }
            // Face
            Circle().fill(Color(hex: 0xFFF1D6)).frame(width: 5.2, height: 5.2).position(x: 31, y: 112)
            Circle().fill(Color(hex: 0xFFF1D6)).frame(width: 5.2, height: 5.2).position(x: 49, y: 112)
            Ellipse().fill(Color(hex: 0xFFF1D6).opacity(0.35)).frame(width: 8, height: 4.4).position(x: 25, y: 117)
            Ellipse().fill(Color(hex: 0xFFF1D6).opacity(0.35)).frame(width: 8, height: 4.4).position(x: 55, y: 117)
            SmilePath()
                .stroke(Color(hex: 0xFFF1D6), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .frame(width: 8, height: 4)
                .position(x: 40, y: 118.5)
        }
        .frame(width: 80, height: 130)
    }
}

private struct PotShape: Shape {
    func path(in r: CGRect) -> Path {
        let sx = r.width / 80, sy = r.height / 130
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x * sx, y: y * sy) }
        var path = Path()
        path.move(to: p(10, 90))
        path.addLine(to: p(70, 90))
        path.addLine(to: p(70, 100))
        path.addLine(to: p(64, 100))
        path.addLine(to: p(60, 128))
        path.addLine(to: p(20, 128))
        path.addLine(to: p(16, 100))
        path.addLine(to: p(10, 100))
        path.closeSubpath()
        return path
    }
}

private struct PlantLeaf: View {
    var body: some View {
        Ellipse().fill(LinearGradient(
            colors: [Color(hex: 0x8FD98A), Color(hex: 0x3E9B55)],
            startPoint: .top, endPoint: .bottom))
    }
}

private struct PlantHop {
    var y = 0.0
    var sx = 1.0
    var sy = 1.0
}

#Preview("Plant stages") {
    ScrollView(.horizontal) {
        HStack(spacing: 16) {
            ForEach([0, 1, 3, 6, 8, 10, 11, 12], id: \.self) { PlantView(count: $0) }
        }
        .padding()
    }
    .background(Color.sunBackgroundTop)
}
