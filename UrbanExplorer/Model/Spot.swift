import Foundation

enum SpotCategory: String, Codable, Hashable, CaseIterable, Identifiable {
    case tapas = "Tapas"
    case restaurant = "Restaurante"
    case market = "Mercado"
    case sweets = "Dulces"
    case museum = "Museo"

    var id: Self { self }

    /// Nombre del SF Symbol que representa la categoría.
    var symbol: String {
        switch self {
        case .tapas: "wineglass.fill"
        case .restaurant: "fork.knife"
        case .market: "basket.fill"
        case .sweets: "birthday.cake.fill"
        case .museum: "building.columns.fill"
        }
    }
}

struct Spot: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let description: String
    let category: SpotCategory
    let rating: Double
    let visitCount: Int
    let isFavorite: Bool
    let createdAt: Date
    let tags: [String]
    let dishes: [String]?
    let imageURL: [URL]
    let mainImageURL: URL
    let webURL: URL?
    let latitude: Double
    let longitude: Double
    let reviews: [Review]

    /// Abre Apple Maps con la ruta en coche hasta el lugar.
    var directionsURL: URL? {
        var components = URLComponents(string: "https://maps.apple.com/")
        components?.queryItems = [
            URLQueryItem(name: "daddr", value: "\(latitude),\(longitude)"),
            URLQueryItem(name: "dirflg", value: "d")
        ]
        return components?.url
    }
}
