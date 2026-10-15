import SwiftUI

struct RecapView: View {
    @Environment(\.dismiss) private var dismiss
    let entries: [GratitudeEntry]
    let cadence: ReviewCadence

    private var periodStart: Date {
        Calendar.current.date(byAdding: cadence.component, value: -1, to: .now) ?? .now
    }

    private var periodEntries: [GratitudeEntry] {
        entries.filter { $0.createdAt >= periodStart }.sorted { $0.createdAt > $1.createdAt }
    }

    private var topCategories: [(GratitudeCategory, Int)] {
        let counts = periodEntries.flatMap(\.categories).reduce(into: [GratitudeCategory: Int]()) {
            $0[$1, default: 0] += 1
        }
        return counts.sorted { $0.value > $1.value }.prefix(3).map { ($0.key, $0.value) }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                GrainBackground()
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 6) {
                            Text("\(periodEntries.count)")
                                .font(.system(size: 64, weight: .heavy, design: .rounded))
                                .foregroundStyle(Color.sunAccentText)
                                .contentTransition(.numericText())
                            Text(cadence == .weekly ? "SunDrops this week" : "SunDrops this month")
                                .font(.system(.headline, design: .rounded))
                                .foregroundStyle(Color.sunInk)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .fill(Color.sunSurface))
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .strokeBorder(Color.raspberryRed.opacity(0.35), lineWidth: 1.5))

                        if !topCategories.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Most grateful for")
                                    .font(.system(.headline, design: .rounded))
                                    .foregroundStyle(Color.sunInk)
                                ForEach(topCategories, id: \.0) { category, count in
                                    HStack {
                                        Text("\(category.emoji) \(category.title)")
                                        Spacer()
                                        Text("\(count)").fontWeight(.bold)
                                    }
                                    .font(.system(.body, design: .rounded))
                                    .foregroundStyle(Color.sunInk)
                                    .padding(12)
                                    .background(RoundedRectangle(cornerRadius: 14).fill(Color.sunSurface))
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Your SunDrops")
                                .font(.system(.headline, design: .rounded))
                                .foregroundStyle(Color.sunInk)
                            if periodEntries.isEmpty {
                                Text("Nothing yet. Drop one in and it will show up here.")
                                    .font(.system(.body, design: .rounded))
                                    .foregroundStyle(Color.sunInk.opacity(0.7))
                            }
                            ForEach(periodEntries) { entry in
                                VStack(alignment: .leading, spacing: 8) {
                                    if let data = entry.photoData, let image = UIImage(data: data) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 140)
                                            .frame(maxWidth: .infinity)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    if let video = entry.videoFilename, MediaStore.videoExists(video) {
                                        EntryVideoPlayer(filename: video)
                                            .frame(height: 180)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    Text(entry.text.isEmpty ? "(photo or video memory)" : entry.text)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundStyle(Color.sunInk)
                                    Text(entry.createdAt.formatted(date: .abbreviated, time: .omitted))
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundStyle(Color.sunInk.opacity(0.6))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .fill(Color.sunSurface)
                                        .shadow(color: .black.opacity(0.1), radius: 3, y: 2))
                            }
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Jar Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.tint(Color.sunAccentText)
                }
            }
        }
    }
}
