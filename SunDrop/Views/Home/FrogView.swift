import SwiftUI

/// A cute, chubby pastel blue frog with a sprout on its head.
/// The sprout grows a leaf for each day of your streak (up to six).
struct FrogView: View {
    /// Number of leaves on the sprout, 0...6
    let leaves: Int
    /// Bump this number to make the frog hop (used when it is tapped).
    var hopTrigger: Int = 0

    @State private var sway = false
    @State private var breathe = false
    @State private var blink = false

    private let maxLeaves = 6
    private let skin = Color(hex: 0xA8D8F0)
    private let skinLight = Color(hex: 0xBFE6F7)
    private let skinDeep = Color(hex: 0x8CC7E8)
    private let belly = Color(hex: 0xE4F4FB)
    private let stem = Color(hex: 0x4F9D5D)

    var body: some View {
        ZStack {
            frog
                .scaleEffect(x: 1, y: breathe ? 1.035 : 1, anchor: .bottom)
                .position(x: 40, y: 95)
            sprout
        }
        .frame(width: 80, height: 130)
        .animation(.spring(response: 0.6, dampingFraction: 0.55), value: leaves)
        .keyframeAnimator(initialValue: FrogHop(), trigger: hopTrigger) { content, value in
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
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) { breathe = true }
        }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(Double.random(in: 3...5)))
                withAnimation(.easeInOut(duration: 0.08)) { blink = true }
                try? await Task.sleep(for: .milliseconds(140))
                withAnimation(.easeInOut(duration: 0.08)) { blink = false }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Cheerful frog with \(min(leaves, maxLeaves)) leaves on its sprout")
    }

    // MARK: Frog (80 x 70 drawing space, bottom aligned in the 80 x 130 frame)

    private var frog: some View {
        ZStack {
            // Feet
            Ellipse().fill(skinDeep).frame(width: 24, height: 12).position(x: 20, y: 64)
            Ellipse().fill(skinDeep).frame(width: 24, height: 12).position(x: 60, y: 64)
            // Eye bumps
            Circle().fill(skin).frame(width: 24, height: 24).position(x: 24, y: 17)
            Circle().fill(skin).frame(width: 24, height: 24).position(x: 56, y: 17)
            // Chubby body and belly
            Ellipse()
                .fill(LinearGradient(colors: [skinLight, skin, skinDeep], startPoint: .top, endPoint: .bottom))
                .frame(width: 68, height: 56)
                .position(x: 40, y: 42)
            Ellipse().fill(belly).frame(width: 38, height: 28).position(x: 40, y: 52)
            // Little hands
            Capsule().fill(skinDeep).frame(width: 12, height: 16)
                .rotationEffect(.degrees(14)).position(x: 9, y: 52)
            Capsule().fill(skinDeep).frame(width: 12, height: 16)
                .rotationEffect(.degrees(-14)).position(x: 71, y: 52)
            // Face
            eye(x: 24)
            eye(x: 56)
            Circle().fill(Color(hex: 0x6FB0D6)).frame(width: 2.5, height: 2.5).position(x: 37, y: 32)
            Circle().fill(Color(hex: 0x6FB0D6)).frame(width: 2.5, height: 2.5).position(x: 43, y: 32)
            Ellipse().fill(Color.raspberryRed.opacity(0.3)).frame(width: 11, height: 6).position(x: 15, y: 40)
            Ellipse().fill(Color.raspberryRed.opacity(0.3)).frame(width: 11, height: 6).position(x: 65, y: 40)
            SmilePath()
                .stroke(Color.vintageBerry, style: StrokeStyle(lineWidth: 2.2, lineCap: .round))
                .frame(width: 16, height: 5)
                .position(x: 40, y: 41)
        }
        .frame(width: 80, height: 70)
    }

    private func eye(x: CGFloat) -> some View {
        ZStack {
            Circle().fill(.white).frame(width: 16, height: 16)
            Capsule().fill(Color.vintageBerry).frame(width: 7, height: blink ? 1.5 : 10)
            Circle().fill(.white).frame(width: 3, height: 3)
                .offset(x: 1.5, y: -2)
                .opacity(blink ? 0 : 1)
        }
        .position(x: x, y: 17)
    }

    // MARK: Sprout (grows with the streak)

    private var sprout: some View {
        let n = min(leaves, maxLeaves)
        let stemHeight = CGFloat(8 + n * 7)
        return ZStack(alignment: .bottom) {
            Capsule().fill(stem).frame(width: 4, height: stemHeight)
            if n == 0 {
                Ellipse().fill(Color(hex: 0x7BC47F))
                    .frame(width: 9, height: 12)
                    .offset(y: -stemHeight + 4)
            }
            ForEach(0..<n, id: \.self) { i in
                FrogLeaf(flip: i.isMultiple(of: 2))
                    .frame(width: 20, height: 10)
                    .offset(x: i.isMultiple(of: 2) ? -12 : 12, y: -CGFloat(6 + i * 7))
                    .transition(.scale(scale: 0.1, anchor: .bottom).combined(with: .opacity))
            }
        }
        .frame(width: 60, height: 60, alignment: .bottom)
        .rotationEffect(.degrees(sway ? 4 : -4), anchor: .bottom)
        .position(x: 40, y: 44) // base of the stem sits on the frog's head at y = 74
    }
}

private struct FrogHop {
    var y = 0.0
    var sx = 1.0
    var sy = 1.0
}

private struct FrogLeaf: View {
    var flip: Bool

    var body: some View {
        Ellipse()
            .fill(LinearGradient(
                colors: [Color(hex: 0x7BC47F), Color(hex: 0x4F9D5D)],
                startPoint: .top, endPoint: .bottom))
            .rotationEffect(.degrees(flip ? -25 : 25))
    }
}

#Preview("Frog") {
    HStack(spacing: 24) {
        FrogView(leaves: 0)
        FrogView(leaves: 3)
        FrogView(leaves: 6)
    }
    .padding()
    .background(Color.sunBackgroundTop)
}
