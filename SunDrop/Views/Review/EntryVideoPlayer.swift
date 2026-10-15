import SwiftUI
import AVKit

/// Plays a video saved in the app's Documents/Videos folder.
struct EntryVideoPlayer: View {
    let filename: String
    @State private var player: AVPlayer?

    var body: some View {
        Group {
            if let player {
                VideoPlayer(player: player)
            } else {
                Color.clear
            }
        }
        .onAppear {
            guard player == nil, MediaStore.videoExists(filename) else { return }
            player = AVPlayer(url: MediaStore.videoURL(for: filename))
        }
        .onDisappear { player?.pause() }
    }
}
