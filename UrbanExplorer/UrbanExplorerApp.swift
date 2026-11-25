import SwiftUI

@main
struct UrbanExplorerApp: App {
    private let spots: [Spot]
    @State private var favorites: FavoritesStore
    @State private var images = ImageStore()
    @State private var showsLaunchAnimation = true
    @State private var contentRevealed = false

    init() {
        let spots = JSONLoader.cargarSpotsParaLaApp()
        self.spots = spots
        _favorites = State(initialValue: FavoritesStore(seed: spots))
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                SpotListView(spots: spots)
                    .revealsFromBottom(contentRevealed)

                if showsLaunchAnimation {
                    LaunchAnimationView(preload: preloadImages) {
                        withAnimation(.easeOut(duration: 1.3)) { contentRevealed = true }
                        withAnimation(.easeInOut(duration: 0.5)) { showsLaunchAnimation = false }
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
            .environment(favorites)
            .environment(images)
            .fontDesign(.serif)
        }
    }

    /// Foto de la lista y primera foto del detalle de cada lugar.
    private func preloadImages() async {
        let urls = spots.flatMap { spot in
            [spot.mainImageURL] + spot.imageURL.prefix(1)
        }
        await images.preload(urls)
    }
}
