import Foundation
import Observation

/// Guarda en UserDefaults los ids de los lugares favoritos.
@MainActor
@Observable
final class FavoritesStore {
    private static let storageKey = "favoriteSpotIDs"

    private(set) var ids: Set<UUID>
    private let defaults: UserDefaults

    /// La primera vez se usan los `isFavorite` del JSON; después, lo guardado.
    init(seed spots: [Spot], defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let saved = defaults.stringArray(forKey: Self.storageKey) {
            ids = Set(saved.compactMap(UUID.init(uuidString:)))
        } else {
            ids = Set(spots.filter(\.isFavorite).map(\.id))
        }
    }

    func contains(_ spot: Spot) -> Bool {
        ids.contains(spot.id)
    }

    func toggle(_ spot: Spot) {
        if ids.contains(spot.id) {
            ids.remove(spot.id)
        } else {
            ids.insert(spot.id)
        }
        defaults.set(ids.map(\.uuidString), forKey: Self.storageKey)
    }
}
