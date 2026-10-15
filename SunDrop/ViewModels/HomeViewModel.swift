import SwiftUI
import SwiftData
import Observation
import UIKit

/// Data collected by the add sheet.
struct NewEntryDraft {
    var text = ""
    var categories: Set<GratitudeCategory> = []
    var photoData: Data?
    var videoURL: URL?
}

@MainActor
@Observable
final class HomeViewModel {
    // Sheets
    var showAddSheet = false
    var showRecap = false
    var showSettings = false
    var reminisceEntry: GratitudeEntry?

    // Jar animation state
    var droppingSlipColorIndex: Int?
    var isWinking = false
    var lidOpen = false
    var bounceTrigger = 0

    private(set) var isDropping = false

    // Plant cheer
    static let cheers = [
        "You are glowing today!",
        "Little joys add up. Keep going!",
        "Look at you, growing every day!",
        "The world is brighter with you in it.",
        "Proud of you for noticing the good."
    ]
    var cheerMessage: String?
    var plantHopTrigger = 0
    private var lastCheerIndex: Int?
    private var cheerTask: Task<Void, Never>?

    /// Opens the add sheet unless a drop animation is still playing.
    func openAdd() {
        guard !isDropping else { return }
        showAddSheet = true
    }

    /// Makes the plant hop and shows a random positive message (never the same one twice in a row).
    func cheerUp() {
        var index = Int.random(in: 0..<Self.cheers.count)
        while index == lastCheerIndex { index = Int.random(in: 0..<Self.cheers.count) }
        lastCheerIndex = index
        let message = Self.cheers[index]

        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        plantHopTrigger += 1
        withAnimation(.spring(response: 0.45, dampingFraction: 0.6)) { cheerMessage = message }
        UIAccessibility.post(notification: .announcement, argument: message)

        cheerTask?.cancel()
        cheerTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(3.2))
            guard !Task.isCancelled else { return }
            withAnimation(.easeIn(duration: 0.25)) { self?.cheerMessage = nil }
        }
    }

    /// Choreographs the drop: lid lifts, slip falls, jar squishes and winks.
    func add(draft: NewEntryDraft, context: ModelContext) async {
        guard !isDropping else { return }
        isDropping = true
        defer { isDropping = false }

        let colorIndex = Int.random(in: 0..<Color.slipPalette.count)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { lidOpen = true }
        droppingSlipColorIndex = colorIndex

        try? await Task.sleep(for: .milliseconds(800))

        var videoName: String?
        if let url = draft.videoURL { videoName = MediaStore.saveVideo(from: url) }

        let entry = GratitudeEntry(
            text: draft.text.trimmingCharacters(in: .whitespacesAndNewlines),
            categories: Array(draft.categories),
            photoData: draft.photoData,
            videoFilename: videoName,
            slipColorIndex: colorIndex)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.65)) {
            context.insert(entry)
            droppingSlipColorIndex = nil
        }
        try? context.save()

        bounceTrigger += 1
        isWinking = true
        UINotificationFeedbackGenerator().notificationOccurred(.success)

        try? await Task.sleep(for: .milliseconds(300))
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) { lidOpen = false }
        try? await Task.sleep(for: .milliseconds(900))
        isWinking = false
    }

    /// Pulls a random memory from the jar.
    func reminisce(from entries: [GratitudeEntry]) {
        guard let pick = entries.randomElement() else {
            Task { await wink() }
            return
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        reminisceEntry = pick
    }

    private func wink() async {
        bounceTrigger += 1
        isWinking = true
        try? await Task.sleep(for: .milliseconds(900))
        isWinking = false
    }

    func streak(entries: [GratitudeEntry]) -> Int {
        StreakCalculator.streak(days: entries.map(\.createdAt))
    }

    func greeting(name: String, now: Date = .now) -> String {
        let hour = Calendar.current.component(.hour, from: now)
        let part: String
        switch hour {
        case 5..<12: part = "Good morning"
        case 12..<17: part = "Good afternoon"
        case 17..<22: part = "Good evening"
        default: part = "Hello, night owl"
        }
        return name.isEmpty ? part : "\(part), \(name)"
    }
}
