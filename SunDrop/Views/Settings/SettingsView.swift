import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage(SettingsKey.userName) private var userName = ""
    @AppStorage(SettingsKey.appearanceMode) private var appearanceRaw = AppearanceMode.system.rawValue
    @AppStorage(SettingsKey.reviewCadence) private var cadenceRaw = ReviewCadence.weekly.rawValue
    @AppStorage(SettingsKey.reminderMinutes) private var reminderMinutes = 20 * 60
    @AppStorage(SettingsKey.remindersEnabled) private var remindersEnabled = true

    private var reminderDate: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(
                    bySettingHour: reminderMinutes / 60,
                    minute: reminderMinutes % 60,
                    second: 0, of: .now) ?? .now
            },
            set: { newValue in
                let c = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                reminderMinutes = (c.hour ?? 20) * 60 + (c.minute ?? 0)
            })
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("You") {
                    TextField("Your name", text: $userName)
                        .textContentType(.givenName)
                }
                .listRowBackground(Color.sunSurface)

                Section {
                    Picker("Appearance", selection: $appearanceRaw) {
                        ForEach(AppearanceMode.allCases) { mode in
                            Label(mode.title, systemImage: mode.symbol).tag(mode.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Look")
                } footer: {
                    Text("Night mode swaps the beige paper for a cozy Dusk Blue evening. Auto follows your phone.")
                }
                .listRowBackground(Color.sunSurface)

                Section("Daily reminder") {
                    Toggle("Remind me", isOn: $remindersEnabled)
                    if remindersEnabled {
                        DatePicker("Time", selection: reminderDate, displayedComponents: .hourAndMinute)
                    }
                }
                .listRowBackground(Color.sunSurface)

                Section("Jar review") {
                    Picker("Cadence", selection: $cadenceRaw) {
                        ForEach(ReviewCadence.allCases) { c in
                            Text(c.title).tag(c.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .listRowBackground(Color.sunSurface)
            }
            .scrollContentBackground(.hidden)
            .background(GrainBackground())
            .foregroundStyle(Color.sunInk)
            .tint(Color.sunAccentText)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.fontWeight(.bold)
                }
            }
            .onChange(of: reminderMinutes) { _, _ in reschedule() }
            .onChange(of: userName) { _, _ in reschedule() }
            .onChange(of: remindersEnabled) { _, enabled in
                if enabled {
                    Task {
                        let granted = await NotificationService.shared.requestAuthorization()
                        if granted { reschedule() } else { remindersEnabled = false }
                    }
                } else {
                    NotificationService.shared.cancelDailyReminder()
                }
            }
        }
    }

    private func reschedule() {
        guard remindersEnabled else { return }
        let minutes = reminderMinutes
        let name = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        Task {
            await NotificationService.shared.scheduleDailyReminder(
                minutesSinceMidnight: minutes, name: name)
        }
    }
}

#Preview {
    SettingsView()
}
