import SwiftUI

struct ReminisceView: View {
    @Environment(\.dismiss) private var dismiss
    let entry: GratitudeEntry
    var onAnother: () -> Void

    var body: some View {
        ZStack {
            GrainBackground()
            ScrollView {
                VStack(spacing: 18) {
                    Text("A memory from your jar")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(Color.sunInk.opacity(0.7))

                    VStack(alignment: .leading, spacing: 12) {
                        if let data = entry.photoData, let image = UIImage(data: data) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 180)
                                .frame(maxWidth: .infinity)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        if let video = entry.videoFilename, MediaStore.videoExists(video) {
                            EntryVideoPlayer(filename: video)
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        if !entry.text.isEmpty {
                            Text(entry.text)
                                .font(.system(.title3, design: .rounded, weight: .semibold))
                                .foregroundStyle(Color.sunInk)
                        }
                        if !entry.categories.isEmpty {
                            Text(entry.categories.map { "\($0.emoji) \($0.title)" }.joined(separator: "  "))
                                .font(.system(.footnote, design: .rounded))
                                .foregroundStyle(Color.sunAccentText)
                        }
                        Text(entry.createdAt.formatted(date: .complete, time: .omitted))
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(Color.sunInk.opacity(0.6))
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.sunSurface)
                            .shadow(color: .black.opacity(0.18), radius: 8, y: 5))
                    .rotationEffect(.degrees(-1.5))
                    .padding(.horizontal, 24)

                    HStack(spacing: 12) {
                        Button("Another one") { onAnother() }
                            .buttonStyle(SunButtonStyle(fill: .sunSecondary, foreground: .sunOnSecondary))
                        Button("Done") { dismiss() }
                            .buttonStyle(SunButtonStyle())
                    }
                }
                .padding(.vertical, 28)
            }
        }
        .id(entry.id)
        .transition(.scale.combined(with: .opacity))
    }
}
