import SwiftUI

/// A potted plant that grows every time a SunDrop is added to the jar.
///
/// - 0 drops: a little sprout
/// - 1–5: a new stem section and a new leaf with every drop
/// - 6: a sunflower bud pops up
/// - 7+: the sunflower blooms, with a confetti celebration
struct PlantView: View {
    /// Number of SunDrops in the jar.
    let count: Int
    /// Bump this number to make the plant hop (used when it is tapped).
    var hopTrigger: Int = 0

    static let bloomAt = 7

    @State private var sway = false
    @State private var burst = false
    @State private var showConfetti = false

    private let stemColor = Color(hex: 0x4F9D5D)

    private var n: Int { max(0, count) }
    /// Stem height in points for each number of drops. It shoots up and ends taller than the jar.
    private static let heights: [CGFloat] = [20, 70, 118, 160, 198, 236, 262, 276]
    /// Extra drawing space above the pot, so the plant can grow past its layout frame.
    private static let lift: CGFloat = 300
    private var stemHeight: CGFloat { Self.heights[min(n, Self.heights.count - 1)] }
    private var leafCount: Int { min(n, 5) }
    private var isBloomed: Bool { n >= Self.bloomAt }
    private var soilY: CGFloat { Self.lift + 94 }
    private var headY: CGFloat { soilY - stemHeight }

    var body: some View {
        ZStack(alignment: .bottom) {
            plant
                .rotationEffect(.degrees(sway ? 1.6 : -1.6),
                                anchor: UnitPoint(x: 0.5, y: soilY / (130 + Self.lift)))
            pot
        }
        .frame(width: 80, height: 130, alignment: .bottom)
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
        .overlay(alignment: .top) { confetti }
        .onChange(of: n) { old, new in
            if old < Self.bloomAt, new >= Self.bloomAt { celebrate() }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(stageDescription)
    }

    // MARK: Celebration

    private static let confettiColors: [Color] = [
        .sunflowerGold, .raspberryRed, .frostedBlue, .sunTeal, .sunflowerGoldLight, .vintageBerry
    ]

    /// Pre-rolled so every burst is laid out the same way during one animation.
    private let pieces: [(dx: CGFloat, dy: CGFloat, spin: Double, size: CGFloat)] = (0..<30).map { _ in
        let angle = Double.random(in: -150 ... -30) * .pi / 180
        let distance = CGFloat.random(in: 70...170)
        return (CGFloat(cos(angle)) * distance, CGFloat(sin(angle)) * distance,
                Double.random(in: -540...540), CGFloat.random(in: 6...10))
    }

    @ViewBuilder private var confetti: some View {
        if showConfetti {
            ZStack {
                ForEach(0..<pieces.count, id: \.self) { i in
                    let piece = pieces[i]
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Self.confettiColors[i % Self.confettiColors.count])
                        .frame(width: piece.size, height: piece.size * 1.5)
                        .rotationEffect(.degrees(burst ? piece.spin : 0))
                        .offset(x: burst ? piece.dx : 0, y: burst ? piece.dy + 90 : 20)
                        .opacity(burst ? 0 : 1)
                }
            }
            .frame(width: 1, height: 1)
            .offset(y: 94 - Self.heights[Self.heights.count - 1])
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        }
    }

    private func celebrate() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        burst = false
        showConfetti = true
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(500))
            withAnimation(.easeOut(duration: 1.8)) { burst = true }
            try? await Task.sleep(for: .seconds(2.2))
            showConfetti = false
            burst = false
        }
    }

    private var stageDescription: String {
        switch n {
        case 0: "A little sprout in the pot. Add a SunDrop to help it grow."
        case 1..<(Self.bloomAt - 1): "A growing plant with \(leafCount) \(leafCount == 1 ? "leaf" : "leaves")."
        case Self.bloomAt - 1: "A sunflower bud has popped up."
        default: "A sunflower in full bloom!"
        }
    }

    // MARK: Plant (80 wide, grows upward from the soil line)

    private var plant: some View {
        ZStack {
            // Stem
            Capsule()
                .fill(stemColor)
                .frame(width: 6, height: stemHeight + 4)
                .position(x: 40, y: soilY - stemHeight / 2 + 2)

            // Sprout seed leaves (before the first real leaves)
            if n == 0 {
                let sc: CGFloat = 6.5
                PlantLeaf().frame(width: sc * 2, height: sc)
                    .rotationEffect(.degrees(-25)).position(x: 40 - sc - 1, y: headY + 3)
                PlantLeaf().frame(width: sc * 2, height: sc)
                    .rotationEffect(.degrees(25)).position(x: 40 + sc + 1, y: headY + 3)
            }

            // Leaves
            ForEach(0..<leafCount, id: \.self) { i in
                let left = i.isMultiple(of: 2)
                let offset = min(CGFloat(16 + i * 40), stemHeight - 14)
                PlantLeaf()
                    .frame(width: 32, height: 16)
                    .rotationEffect(.degrees(left ? -28 : 28))
                    .position(x: left ? 24 : 56, y: soilY - offset)
                    .transition(.scale(scale: 0.1).combined(with: .opacity))
            }

            // Bud and sunflower
            if n >= Self.bloomAt - 1 {
                head
                    .scaleEffect(1.3)
                    .position(x: 40, y: headY)
                    .transition(.scale(scale: 0.3).combined(with: .opacity))
            }
        }
        .frame(width: 80, height: 130 + Self.lift)
    }

    private static let seedSpots: [CGPoint] = [
        CGPoint(x: -4, y: -3), CGPoint(x: 4, y: -3), CGPoint(x: 0, y: 1),
        CGPoint(x: -5, y: 4), CGPoint(x: 5, y: 4)
    ]

    private var head: some View {
        ZStack {
            if isBloomed {
                ForEach(0..<12, id: \.self) { k in
                    Ellipse()
                        .fill(LinearGradient(
                            colors: [Color(hex: 0xFFD66B), Color(hex: 0xFFB02E)],
                            startPoint: .top, endPoint: .bottom))
                        .frame(width: 10.4, height: 20)
                        .offset(y: -17)
                        .rotationEffect(.degrees(Double(k) * 30))
                }
                Circle()
                    .fill(RadialGradient(
                        colors: [Color(hex: 0x8A5A3C), Color(hex: 0x4E2E1E)],
                        center: UnitPoint(x: 0.4, y: 0.35), startRadius: 0, endRadius: 14))
                    .frame(width: 22, height: 22)
                ForEach(0..<Self.seedSpots.count, id: \.self) { i in
                    Circle().fill(Color(hex: 0x5A3322).opacity(0.75))
                        .frame(width: 2.4, height: 2.4)
                        .offset(x: Self.seedSpots[i].x, y: Self.seedSpots[i].y)
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
            PotShape().fill(Color.terracotta)
            PotShade().fill(Color.terracottaDeep.opacity(0.55))
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color.terracottaLight)
                .frame(width: 64, height: 12)
                .position(x: 40, y: 94)
            // Soil
            Ellipse().fill(Color(hex: 0x6B4632)).frame(width: 54, height: 9).position(x: 40, y: 89.5)
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

private struct PotShade: Shape {
    func path(in r: CGRect) -> Path {
        let sx = r.width / 80, sy = r.height / 130
        var path = Path()
        path.move(to: CGPoint(x: 60 * sx, y: 100 * sy))
        path.addLine(to: CGPoint(x: 56 * sx, y: 128 * sy))
        path.addLine(to: CGPoint(x: 60 * sx, y: 128 * sy))
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
            ForEach([0, 1, 2, 3, 5, 6, 7], id: \.self) { PlantView(count: $0) }
        }
        .padding()
    }
    .background(Color.sunBackgroundTop)
}
