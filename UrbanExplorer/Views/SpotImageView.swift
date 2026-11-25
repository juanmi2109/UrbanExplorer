import SwiftUI

/// Muestra la foto desde `ImageStore` o, si no está, el placeholder local.
struct SpotImageView: View {
    let url: URL?

    @Environment(ImageStore.self) private var store

    var body: some View {
        Group {
            if let url, let image = store.image(for: url) {
                Image(uiImage: image).resizable().scaledToFill()
            } else {
                Image("SpotPlaceholder").resizable().scaledToFill()
            }
        }
        // Reintenta si la precarga no llegó a tiempo.
        .task(id: url) {
            if let url { await store.load(url) }
        }
        .accessibilityHidden(true)
    }
}
