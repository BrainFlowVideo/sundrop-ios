import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var scheme
    @Query(sort: \GratitudeEntry.createdAt) private var entries: [GratitudeEntry]

    @AppStorage(SettingsKey.userName) private var userName = ""
    @AppStorage(SettingsKey.reviewCadence) private var cadenceRaw = ReviewCadence.weekly.rawValue
    @AppStorage(SettingsKey.jarStartDate) private var jarStart = Date.now.timeIntervalSince1970

    @State private var vm = HomeViewModel()

    private var cadence: ReviewCadence { ReviewCadence(rawValue: cadenceRaw) ?? .weekly }
    private var daysUntilReview: Int {
        ReviewSchedule.daysUntilReview(
            start: Date(timeIntervalSince1970: jarStart), cadence: cadence)
    }

    var body: some View {
        @Bindable var vm = vm

        ZStack {
            GrainBackground()

            SparkleField(count: 12, tint: scheme == .dark ? .sunflowerGold : .raspberryRed)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 18) {
                header
                countdownPill

                Spacer(minLength: 0)

                HStack(alignment: .bottom, spacing: 8) {
                    JarView(
                        entries: entries,
                        droppingColorIndex: vm.droppingSlipColorIndex,
                        isWinking: vm.isWinking,
                        lidOpen: vm.lidOpen,
                        bounceTrigger: vm.bounceTrigger)
                        .contentShape(Rectangle())
                        .onTapGesture { vm.openAdd() }
                        .accessibilityAddTraits(.isButton)
                        .accessibilityHint("Opens the add SunDrop screen")
                    PlantView(count: entries.count, hopTrigger: vm.plantHopTrigger)
                        .padding(.bottom, 4)
                        .onTapGesture { vm.cheerUp() }
                        .accessibilityAddTraits(.isButton)
                        .accessibilityHint("Tap for a little cheer")
                        .overlay(alignment: .topTrailing) {
                            if let message = vm.cheerMessage {
                                CheerBubble(text: message)
                                    .offset(y: -78)
                                    .transition(.scale(scale: 0.4, anchor: .bottomTrailing).combined(with: .opacity))
                                    .allowsHitTesting(false)
                            }
                        }
                }

                Text(entries.isEmpty
                     ? "Your jar is waiting for its first SunDrop"
                     : "\(entries.count) SunDrop\(entries.count == 1 ? "" : "s") in your jar")
                    .font(.system(.subheadline, design: .rounded, weight: .semibold))
                    .foregroundStyle(Color.sunInk.opacity(0.75))
                    .contentTransition(.numericText())
                    .animation(.spring, value: entries.count)

                Spacer(minLength: 0)

                VStack(spacing: 12) {
                    Button {
                        vm.showAddSheet = true
                    } label: {
                        Label("Add SunDrop", systemImage: "sun.max.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SunButtonStyle())

                    Button {
                        vm.reminisce(from: entries)
                    } label: {
                        Label("Shake to reminisce", systemImage: "iphone.radiowaves.left.and.right")
                            .font(.system(.footnote, design: .rounded, weight: .semibold))
                            .foregroundStyle(Color.sunSecondary)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 12)
            }
            .padding(.top, 8)
        }
        .onShake { vm.reminisce(from: entries) }
        .sheet(isPresented: $vm.showAddSheet) {
            AddSunDropSheet { draft in
                Task { await vm.add(draft: draft, context: context) }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $vm.showRecap) {
            RecapView(entries: entries, cadence: cadence)
                .presentationDetents([.large])
        }
        .sheet(isPresented: $vm.showSettings) {
            SettingsView()
                .presentationDetents([.large])
        }
        .sheet(item: $vm.reminisceEntry) { entry in
            ReminisceView(entry: entry) { vm.reminisce(from: entries) }
                .presentationDetents([.medium, .large])
        }
    }

    // MARK: Pieces

    private var header: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(vm.greeting(name: userName))
                    .font(.system(.title2, design: .rounded, weight: .heavy))
                    .foregroundStyle(Color.sunInk)
                Text("What made you smile today?")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(Color.sunInk.opacity(0.65))
            }
            Spacer()
            circleButton("chart.bar.doc.horizontal.fill", label: "Open recap",
                         fill: .sunSecondary, ink: .sunOnSecondary) { vm.showRecap = true }
            circleButton("gearshape.fill", label: "Open settings",
                         fill: .sunSurface, ink: .sunInk) { vm.showSettings = true }
        }
        .padding(.horizontal, 24)
    }

    private func circleButton(
        _ symbol: String, label: String, fill: Color, ink: Color, action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.headline)
                .foregroundStyle(ink)
                .frame(width: 44, height: 44)
                .background(Circle().fill(fill))
                .overlay(Circle().strokeBorder(.white.opacity(0.2), lineWidth: 1))
                .shadow(color: .black.opacity(0.18), radius: 6, y: 3)
        }
        .accessibilityLabel(label)
    }

    private var countdownPill: some View {
        Button {
            vm.showRecap = true
        } label: {
            Text(daysUntilReview == 0
                 ? "Jar review is today!"
                 : "\(daysUntilReview) day\(daysUntilReview == 1 ? "" : "s") until Jar Review")
                .contentTransition(.numericText())
            .font(.system(.footnote, design: .rounded, weight: .bold))
            .foregroundStyle(Color.sunInk)
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .background(
                Capsule()
                    .fill(Color.sunSurface)
                    .overlay(Capsule().strokeBorder(Color.raspberryRed.opacity(0.4), lineWidth: 1.5))
                    .shadow(color: scheme == .dark ? .black.opacity(0.3) : Color.sunflowerGold.opacity(0.5),
                            radius: 8, y: 3)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview("Day") {
    HomeView()
        .modelContainer(for: GratitudeEntry.self, inMemory: true)
}

#Preview("Night") {
    HomeView()
        .modelContainer(for: GratitudeEntry.self, inMemory: true)
        .preferredColorScheme(.dark)
}
