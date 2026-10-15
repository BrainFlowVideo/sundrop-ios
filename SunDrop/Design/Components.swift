import SwiftUI

// MARK: - Sun

/// A glowing, softly rotating sun. The face makes it kawaii.
struct SunBurst: View {
    var size: CGFloat = 220
    var showsFace = true
    @State private var angle: Double = 0
    @State private var bob = false

    var body: some View {
        ZStack {
            Circle()
                .fill(RadialGradient(
                    colors: [Color.sunflowerGold.opacity(0.9), Color.sunflowerGold.opacity(0)],
                    center: .center, startRadius: size * 0.2, endRadius: size * 0.75))
                .frame(width: size * 1.5, height: size * 1.5)

            ZStack {
                ForEach(0..<12, id: \.self) { i in
                    Capsule()
                        .fill(Color.sunflowerGold.opacity(0.95))
                        .frame(width: size * 0.07, height: size * 0.16)
                        .offset(y: -size * 0.5)
                        .rotationEffect(.degrees(Double(i) * 30))
                }
            }
            .rotationEffect(.degrees(angle))

            Circle()
                .fill(LinearGradient(
                    colors: [.sunflowerGoldLight, .sunflowerGold],
                    startPoint: .top, endPoint: .bottom))
                .frame(width: size * 0.68, height: size * 0.68)
                .shadow(color: .sunflowerGold.opacity(0.5), radius: 18, y: 8)
                .overlay(alignment: .topLeading) {
                    Circle().fill(.white.opacity(0.35))
                        .frame(width: size * 0.16, height: size * 0.1)
                        .offset(x: size * 0.12, y: size * 0.1)
                        .blur(radius: 2)
                }

            if showsFace {
                VStack(spacing: size * 0.03) {
                    HStack(spacing: size * 0.16) {
                        eye
                        eye
                    }
                    SmilePath()
                        .stroke(Color.vintageBerry, style: StrokeStyle(lineWidth: size * 0.02, lineCap: .round))
                        .frame(width: size * 0.14, height: size * 0.06)
                }
                .overlay {
                    HStack(spacing: size * 0.3) {
                        blush
                        blush
                    }
                    .offset(y: size * 0.04)
                }
            }
        }
        .frame(width: size * 1.5, height: size * 1.5)
        .offset(y: bob ? -6 : 6)
        .onAppear {
            withAnimation(.linear(duration: 40).repeatForever(autoreverses: false)) { angle = 360 }
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) { bob = true }
        }
        .accessibilityHidden(true)
    }

    private var eye: some View {
        Capsule().fill(Color.vintageBerry)
            .frame(width: size * 0.04, height: size * 0.06)
    }

    private var blush: some View {
        Ellipse().fill(Color.raspberryRedLight.opacity(0.4))
            .frame(width: size * 0.09, height: size * 0.05)
    }
}

struct SmilePath: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY),
                       control: CGPoint(x: rect.midX, y: rect.maxY * 1.6))
        return p
    }
}

// MARK: - Paper slip

struct PaperSlip: View {
    var color: Color

    var body: some View {
        RoundedRectangle(cornerRadius: 3, style: .continuous)
            .fill(LinearGradient(colors: [color, color.opacity(0.85)], startPoint: .top, endPoint: .bottom))
            .overlay(
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .strokeBorder(.white.opacity(0.4), lineWidth: 0.6)
            )
            .overlay {
                VStack(spacing: 3) {
                    Rectangle().fill(.black.opacity(0.07)).frame(height: 1)
                    Rectangle().fill(.black.opacity(0.07)).frame(height: 1)
                }
                .padding(.horizontal, 5)
            }
            .shadow(color: .black.opacity(0.15), radius: 1, y: 1)
    }
}

// MARK: - Grain background

/// Warm paper-like background with a deterministic speckle texture.
/// Beige and peach by day, Dusk Blue by night.
struct GrainBackground: View {
    /// Peach on top instead of beige (used on the welcome page).
    var warmTop = false
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ZStack {
            LinearGradient(
                colors: warmTop
                    ? [.sunWarmTop, .sunWarmBottom]
                    : [.sunBackgroundTop, .sunBackgroundBottom],
                startPoint: .top, endPoint: .bottom)
            RadialGradient(
                colors: [Color.sunGlow, .clear],
                center: .init(x: 0.5, y: 0.35), startRadius: 10, endRadius: 380)
            Canvas { [scheme] context, size in
                var seed: UInt64 = 42
                func next() -> Double {
                    seed = seed &* 6364136223846793005 &+ 1442695040888963407
                    return Double((seed >> 33) & 0xFFFF) / 65535
                }
                let ink: Color = scheme == .dark ? .white : .vintageBerry
                for _ in 0..<1400 {
                    let x = next() * size.width
                    let y = next() * size.height
                    let r = 0.4 + next() * 0.9
                    let rect = CGRect(x: x, y: y, width: r, height: r)
                    context.fill(Path(ellipseIn: rect),
                                 with: .color(ink.opacity(0.03 + next() * 0.04)))
                }
            }
            .blendMode(scheme == .dark ? .normal : .multiply)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Buttons

/// Chunky, tactile button that squishes when pressed.
struct SunButtonStyle: ButtonStyle {
    var fill: Color = .raspberryRed
    var foreground: Color = .white

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.title3, design: .rounded, weight: .bold))
            .foregroundStyle(foreground)
            .padding(.horizontal, 28)
            .padding(.vertical, 16)
            .background {
                Capsule()
                    .fill(LinearGradient(
                        colors: [fill.opacity(0.95), fill],
                        startPoint: .top, endPoint: .bottom))
                    .overlay(Capsule().strokeBorder(.white.opacity(0.35), lineWidth: 1.2))
                    .shadow(color: fill.opacity(configuration.isPressed ? 0.2 : 0.45),
                            radius: configuration.isPressed ? 3 : 10,
                            y: configuration.isPressed ? 1 : 6)
            }
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .offset(y: configuration.isPressed ? 3 : 0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
