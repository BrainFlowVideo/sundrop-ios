import Foundation
import SwiftData

@Model
final class GratitudeEntry {
    var id: UUID
    var text: String
    var createdAt: Date
    /// Stored as raw values so SwiftData only deals with primitives.
    var categoryRaws: [String]
    @Attribute(.externalStorage) var photoData: Data?
    /// File name inside the app's Documents/Videos folder.
    var videoFilename: String?
    var slipColorIndex: Int
    /// Stable random seed so each slip keeps its position/tilt inside the jar.
    var slipSeed: Int

    init(
        text: String,
        categories: [GratitudeCategory] = [],
        photoData: Data? = nil,
        videoFilename: String? = nil,
        slipColorIndex: Int,
        createdAt: Date = .now
    ) {
        self.id = UUID()
        self.text = text
        self.createdAt = createdAt
        self.categoryRaws = categories.map(\.rawValue)
        self.photoData = photoData
        self.videoFilename = videoFilename
        self.slipColorIndex = slipColorIndex
        self.slipSeed = Int.random(in: 0..<Int(Int32.max))
    }

    var categories: [GratitudeCategory] {
        categoryRaws.compactMap(GratitudeCategory.init(rawValue:))
    }
}
