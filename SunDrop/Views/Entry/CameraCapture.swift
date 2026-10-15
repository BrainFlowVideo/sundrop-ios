import SwiftUI
import UIKit
import UniformTypeIdentifiers

/// Wraps the system camera so people can snap a photo or record a short clip.
/// Photos come back as JPEG data; videos come back as a temporary file URL
/// (the app copies it into Documents when the SunDrop is saved).
struct CameraCapture: UIViewControllerRepresentable {
    enum Result {
        case photo(Data)
        case video(URL)
    }

    @Binding var isPresented: Bool
    var maxVideoSeconds: TimeInterval = 30
    var onCapture: (Result) -> Void

    /// False on the Simulator and on devices without a camera.
    static var isAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = [UTType.image.identifier, UTType.movie.identifier]
        picker.videoMaximumDuration = maxVideoSeconds
        picker.videoQuality = .typeMedium
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        private let parent: CameraCapture

        init(_ parent: CameraCapture) { self.parent = parent }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let url = info[.mediaURL] as? URL {
                parent.onCapture(.video(stage(url)))
            } else if let image = info[.originalImage] as? UIImage,
                      let data = image.jpegData(compressionQuality: 0.85) {
                parent.onCapture(.photo(data))
            }
            parent.isPresented = false
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }

        /// Copies the recording somewhere we control so the system can't clean it up early.
        private func stage(_ url: URL) -> URL {
            let ext = url.pathExtension.isEmpty ? "mov" : url.pathExtension
            let copy = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString + "." + ext)
            do {
                try FileManager.default.copyItem(at: url, to: copy)
                return copy
            } catch {
                return url
            }
        }
    }
}
