import Foundation

enum MediaStore {
    private static var videosDirectory: URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("Videos", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    /// Copies a captured or picked video into Documents/Videos and returns the stored file name.
    static func saveVideo(from url: URL) -> String? {
        let ext = url.pathExtension.isEmpty ? "mov" : url.pathExtension
        let name = UUID().uuidString + "." + ext
        let destination = videosDirectory.appendingPathComponent(name)
        do {
            try FileManager.default.copyItem(at: url, to: destination)
            return name
        } catch {
            return nil
        }
    }

    static func videoURL(for filename: String) -> URL {
        videosDirectory.appendingPathComponent(filename)
    }

    static func videoExists(_ filename: String) -> Bool {
        FileManager.default.fileExists(atPath: videoURL(for: filename).path)
    }
}
