import SwiftUI

/// Speech bubble that pops up over the plant with a little cheer.
struct CheerBubble: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(.footnote, design: .rounded, weight: .heavy))
            .foregroundStyle(Color.sunInk)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(width: 190)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.sunSurface)
                    .shadow(color: .black.opacity(0.18), radius: 8, y: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.sunInk.opacity(0.2), lineWidth: 1.5))
            .background(alignment: .bottomTrailing) {
                // Little tail pointing down at the plant
                Rectangle()
                    .fill(Color.sunSurface)
                    .frame(width: 14, height: 14)
                    .rotationEffect(.degrees(45))
                    .offset(x: -34, y: 7)
            }
            .accessibilityLabel(text)
    }
}
