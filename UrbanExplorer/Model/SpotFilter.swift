import Foundation

enum SpotSort: String, CaseIterable, Identifiable {
    case featured = "Destacados"
    case rating = "Mejor valorados"
    case visits = "Más visitados"
    case name = "Nombre (A–Z)"

    var id: Self { self }
}

struct SpotFilter: Equatable {
    var category: SpotCategory?
    var onlyFavorites = false
    var searchText = ""
    var sort: SpotSort = .featured

    func apply(to spots: [Spot], favorites: Set<UUID>) -> [Spot] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        let matching = spots.filter { spot in
            if let category, spot.category != category { return false }
            if onlyFavorites, !favorites.contains(spot.id) { return false }
            if query.isEmpty { return true }
            return spot.title.localizedStandardContains(query)
                || spot.description.localizedStandardContains(query)
                || spot.tags.contains { $0.localizedStandardContains(query) }
                || (spot.dishes ?? []).contains { $0.localizedStandardContains(query) }
        }

        switch sort {
        case .featured: return matching
        case .rating: return matching.sorted { $0.rating > $1.rating }
        case .visits: return matching.sorted { $0.visitCount > $1.visitCount }
        case .name: return matching.sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
        }
    }
}
