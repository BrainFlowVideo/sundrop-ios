import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import CoreTransferable

private struct PickedVideo: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { video in
            SentTransferredFile(video.url)
        } importing: { received in
            let ext = received.file.pathExtension.isEmpty ? "mov" : received.file.pathExtension
            let copy = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString + "." + ext)
            try FileManager.default.copyItem(at: received.file, to: copy)
            return PickedVideo(url: copy)
        }
    }
}

struct AddSunDropSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onSave: (NewEntryDraft) -> Void

    @State private var draft = NewEntryDraft()
    @State private var photoItem: PhotosPickerItem?
    @State private var videoItem: PhotosPickerItem?
    @State private var showCamera = false
    @State private var showCameraUnavailable = false
    @FocusState private var focused: Bool

    private var canSave: Bool {
        !draft.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || draft.photoData != nil || draft.videoURL != nil
    }

    var body: some View {
        NavigationStack {
            ZStack {
                GrainBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("What are you grateful for?")
                            .font(.system(.title2, design: .rounded, weight: .heavy))
                            .foregroundStyle(Color.sunInk)

                        TextField("A warm coffee, a kind text, a sunny walk…",
                                  text: $draft.text, axis: .vertical)
                            .lineLimit(3...6)
                            .focused($focused)
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(Color.sunInk)
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color.sunSurface)
                                    .shadow(color: .raspberryRed.opacity(0.2), radius: 8, y: 3))

                        categorySection
                        mediaSection
                    }
                    .padding(24)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Drop it in") {
                        onSave(draft)
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .disabled(!canSave)
                }
            }
            .tint(Color.sunAccentText)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear { focused = true }
        .onChange(of: photoItem) { _, item in
            guard let item else { return }
            Task { draft.photoData = try? await item.loadTransferable(type: Data.self) }
        }
        .onChange(of: videoItem) { _, item in
            guard let item else { return }
            Task { draft.videoURL = (try? await item.loadTransferable(type: PickedVideo.self))?.url }
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraCapture(isPresented: $showCamera) { result in
                switch result {
                case .photo(let data): draft.photoData = data
                case .video(let url): draft.videoURL = url
                }
            }
            .ignoresSafeArea()
        }
        .alert("Camera not available", isPresented: $showCameraUnavailable) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This device doesn't have a camera we can use. You can still attach a photo or video from your library.")
        }
    }

    // MARK: Sections

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tags")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color.sunInk)
            FlowLayout(spacing: 8) {
                ForEach(GratitudeCategory.allCases) { category in
                    let selected = draft.categories.contains(category)
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            if selected { draft.categories.remove(category) }
                            else { draft.categories.insert(category) }
                        }
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    } label: {
                        Text("\(category.emoji) \(category.title)")
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .foregroundStyle(selected ? Color.sunOnSecondary : Color.sunInk)
                            .background(Capsule().fill(selected ? Color.sunSecondary : Color.sunSurface))
                            .overlay(Capsule().strokeBorder(Color.sunSecondary.opacity(0.35), lineWidth: 1))
                            .scaleEffect(selected ? 1.05 : 1)
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(selected ? .isSelected : [])
                }
            }
        }
    }

    private var mediaSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Memories")
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(Color.sunInk)

            HStack(spacing: 10) {
                Button {
                    if CameraCapture.isAvailable { showCamera = true }
                    else { showCameraUnavailable = true }
                } label: {
                    mediaChip("camera.fill", "Camera", fill: .raspberryRed, ink: .white)
                }
                PhotosPicker(selection: $photoItem, matching: .images) {
                    mediaChip("photo.fill", "Photo")
                }
                PhotosPicker(selection: $videoItem, matching: .videos) {
                    mediaChip("video.fill", "Video")
                }
            }

            if let data = draft.photoData, let image = UIImage(data: data) {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(.white, lineWidth: 4))
                        .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                        .rotationEffect(.degrees(-1.5))
                    removeButton(label: "Remove photo") {
                        draft.photoData = nil
                        photoItem = nil
                    }
                }
                .transition(.scale.combined(with: .opacity))
            }

            if draft.videoURL != nil {
                HStack {
                    Image(systemName: "film.fill")
                        .foregroundStyle(Color.sunAccentText)
                    Text("Video attached")
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(Color.sunInk)
                    Spacer()
                    removeButton(label: "Remove video") {
                        draft.videoURL = nil
                        videoItem = nil
                    }
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.sunSurface))
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring, value: draft.photoData)
        .animation(.spring, value: draft.videoURL)
    }

    private func mediaChip(_ symbol: String, _ title: String, fill: Color = .sunSecondary, ink: Color = .sunOnSecondary) -> some View {
        Label(title, systemImage: symbol)
            .font(.system(.subheadline, design: .rounded, weight: .semibold))
            .foregroundStyle(ink)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Capsule().fill(fill))
    }

    private func removeButton(label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .font(.title2)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, Color.black.opacity(0.55))
                .padding(6)
        }
        .accessibilityLabel(label)
    }
}

/// Simple wrapping layout for tag chips.
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0, width: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                y += rowHeight + spacing
                x = 0
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            width = max(width, x - spacing)
        }
        return CGSize(width: width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
