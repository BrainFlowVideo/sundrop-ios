import SwiftUI

// MARK: - Shapes

struct JarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        let neckW = w * 0.7
        let neckX = (w - neckW) / 2
        var p = Path()
        p.move(to: CGPoint(x: neckX, y: h * 0.06))
        p.addLine(to: CGPoint(x: neckX, y: h * 0.14))
        p.addQuadCurve(to: CGPoint(x: w * 0.04, y: h * 0.3),
                       control: CGPoint(x: w * 0.04, y: h * 0.14))
        p.addLine(to: CGPoint(x: w * 0.04, y: h * 0.9))
        p.addQuadCurve(to: CGPoint(x: w * 0.16, y: h), control: CGPoint(x: w * 0.04, y: h))
        p.addLine(to: CGPoint(x: w * 0.84, y: h))
        p.addQuadCurve(to: CGPoint(x: w * 0.96, y: h * 0.9), control: CGPoint(x: w * 0.96, y: h))
        p.addLine(to: CGPoint(x: w * 0.96, y: h * 0.3))
        p.addQuadCurve(to: CGPoint(x: neckX + neckW, y: h * 0.14),
                       control: CGPoint(x: w * 0.96, y: h * 0.14))
        p.addLine(to: CGPoint(x: neckX + neckW, y: h * 0.06))
        p.closeSubpath()
        return p
    }
}

private struct WinkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY),
                       control: CGPoint(x: rect.midX, y: rect.minY - rect.height))
        return p
    }
}

private struct JarSquash {
    var x = 1.0
    var y = 1.0
}

// MARK: - Jar

struct JarView: View {
    /// Entries sorted oldest first.
    let entries: [GratitudeEntry]
    let droppingColorIndex: Int?
    let isWinking: Bool
    let lidOpen: Bool
    let bounceTrigger: Int

    @Environment(\.colorScheme) private var scheme

    private let size = CGSize(width: 230, height: 280)
    private let maxVisibleSlips = 44
    private var isNight: Bool { scheme == .dark }

    var body: some View {
        ZStack {
            // Glass body
            JarShape()
                .fill(LinearGradient(
                    colors: isNight
                        ? [.white.opacity(0.16), .white.opacity(0.04)]
                        : [.white.opacity(0.45), .white.opacity(0.12)],
                    startPoint: .topLeading, endPoint: .bottomTrailing))

            slipsLayer
                .mask(JarShape())

            face

            // Glass edge + glints
            JarShape()
                .stroke(Color.white.opacity(isNight ? 0.5 : 0.75), lineWidth: 3)
            JarShape()
                .stroke(Color.vintageBerry.opacity(0.15), lineWidth: 1)
            glints
        }
        .frame(width: size.width, height: size.height)
        .background {
            // Warm lamp glow behind the jar at night
            if isNight {
                RadialGradient(
                    colors: [Color.sunflowerGold.opacity(0.28), .clear],
                    center: .center, startRadius: 10, endRadius: 210)
                    .frame(width: 400, height: 400)
                    .allowsHitTesting(false)
            }
        }
        .shadow(color: Color.black.opacity(isNight ? 0.35 : 0.14), radius: 14, y: 12)
        .overlay(alignment: .top) { lid }
        .overlay(alignment: .top) {
            if let index = droppingColorIndex {
                FallingSlip(color: Color.slipPalette[index % Color.slipPalette.count])
                    .id(index)
                    .offset(y: -10)
            }
        }
        .overlay(alignment: .bottom) {
            // Soft contact shadow on the "table"
            Ellipse()
                .fill(Color.black.opacity(isNight ? 0.3 : 0.1))
                .frame(width: size.width * 0.9, height: 16)
                .blur(radius: 6)
                .offset(y: 14)
                .allowsHitTesting(false)
        }
        .keyframeAnimator(initialValue: JarSquash(), trigger: bounceTrigger) { content, value in
            content.scaleEffect(x: value.x, y: value.y, anchor: .bottom)
        } keyframes: { _ in
            KeyframeTrack(\.x) {
                SpringKeyframe(1.1, duration: 0.18, spring: .bouncy)
                SpringKeyframe(0.97, duration: 0.2, spring: .bouncy)
                SpringKeyframe(1.0, duration: 0.3, spring: .bouncy)
            }
            KeyframeTrack(\.y) {
                SpringKeyframe(0.88, duration: 0.18, spring: .bouncy)
                SpringKeyframe(1.06, duration: 0.2, spring: .bouncy)
                SpringKeyframe(1.0, duration: 0.3, spring: .bouncy)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Gratitude jar with \(entries.count) SunDrops")
    }

    // MARK: Slips

    private var slipsLayer: some View {
        let visible = Array(entries.suffix(maxVisibleSlips))
        let columns = 4
        let innerMinX = size.width * 0.12
        let innerWidth = size.width * 0.76
        let cell = innerWidth / CGFloat(columns)

        return ZStack {
            ForEach(Array(visible.enumerated()), id: \.element.id) { index, entry in
                let row = index / columns
                let col = index % columns
                let jx = unit(entry.slipSeed, salt: 0) - 0.5
                let jy = unit(entry.slipSeed, salt: 1) - 0.5
                let tilt = (unit(entry.slipSeed, salt: 2) - 0.5) * 50
                let offsetEven: CGFloat = row.isMultiple(of: 2) ? 0 : cell * 0.4

                PaperSlip(color: Color.slipPalette[entry.slipColorIndex % Color.slipPalette.count])
                    .frame(width: 46, height: 20)
                    .rotationEffect(.degrees(tilt))
                    .position(
                        x: innerMinX + cell * (CGFloat(col) + 0.5) + offsetEven + jx * 12,
                        y: size.height - 22 - CGFloat(row) * 17 + jy * 6)
                    .transition(.scale(scale: 0.3).combined(with: .opacity))
            }
        }
        .frame(width: size.width, height: size.height)
    }

    /// Deterministic 0...1 value from a stored seed.
    private func unit(_ seed: Int, salt: Int) -> CGFloat {
        let v = (seed &* (2654435761 &+ salt &* 40503)) & 0xFFFF
        return CGFloat(v) / 65535
    }

    // MARK: Face

    private var face: some View {
        VStack(spacing: 6) {
            HStack(spacing: 44) {
                eye
                if isWinking {
                    WinkShape()
                        .stroke(Color.vintageBerry, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                        .frame(width: 14, height: 6)
                        .transition(.scale)
                } else {
                    eye
                }
            }
            SmilePath()
                .stroke(Color.vintageBerry, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                .frame(width: 22, height: 8)
        }
        .overlay {
            HStack(spacing: 92) {
                blush
                blush
            }
            .offset(y: 8)
        }
        .background {
            // Soft warm patch so the dark ink stays readable at night
            if isNight {
                Ellipse()
                    .fill(Color.sunflowerGold.opacity(0.85))
                    .frame(width: 130, height: 74)
                    .blur(radius: 8)
            }
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isWinking)
        .position(x: size.width / 2, y: size.height * 0.5)
    }

    private var eye: some View {
        Capsule().fill(Color.vintageBerry)
            .frame(width: 10, height: 15)
            .overlay(alignment: .topTrailing) {
                Circle().fill(.white).frame(width: 4, height: 4).offset(x: -1, y: 2)
            }
    }

    private var blush: some View {
        Ellipse().fill(Color.raspberryRed.opacity(0.35))
            .frame(width: 20, height: 11)
    }

    private var glints: some View {
        ZStack {
            Capsule().fill(.white.opacity(isNight ? 0.35 : 0.55))
                .frame(width: 8, height: 120)
                .position(x: size.width * 0.12, y: size.height * 0.52)
            Capsule().fill(.white.opacity(isNight ? 0.25 : 0.4))
                .frame(width: 6, height: 24)
                .position(x: size.width * 0.12, y: size.height * 0.27)
        }
        .allowsHitTesting(false)
    }

    // MARK: Lid

    private var lid: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(LinearGradient(
                    colors: [.sunflowerGoldLight, .sunflowerGold],
                    startPoint: .top, endPoint: .bottom))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(.white.opacity(0.35), lineWidth: 1.2)
                )
        }
        .frame(width: size.width * 0.78, height: 30)
        .shadow(color: .sunflowerGold.opacity(0.5), radius: 5, y: 3)
        .rotationEffect(.degrees(lidOpen ? -16 : 0), anchor: .bottomLeading)
        .offset(x: lidOpen ? -14 : 0, y: lidOpen ? -24 : -10)
    }
}

// MARK: - Falling slip

private struct FallingSlip: View {
    let color: Color
    @State private var landed = false

    var body: some View {
        PaperSlip(color: color)
            .frame(width: 54, height: 24)
            .rotationEffect(.degrees(landed ? 8 : -28))
            .offset(y: landed ? 150 : -140)
            .opacity(landed ? 0.0 : 1)
            .onAppear {
                withAnimation(.spring(response: 0.75, dampingFraction: 0.55)) { landed = true }
            }
            .animation(.easeIn(duration: 0.2).delay(0.6), value: landed)
    }
}
