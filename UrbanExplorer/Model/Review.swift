import Foundation

struct Review: Codable, Identifiable, Hashable {
    // El JSON no trae id, así que se genera uno al decodificar.
    let id = UUID()
    let author: String
    let date: Date
    let comment: String
    let points: Int

    private enum CodingKeys: String, CodingKey {
        case author = "autor"
        case date
        case comment
        case points
    }
}
