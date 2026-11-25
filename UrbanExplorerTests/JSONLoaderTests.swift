import Foundation
import Testing
@testable import UrbanExplorer

struct JSONLoaderTests {
    @Test("El spots.json del Bundle contiene entre 8 y 10 lugares")
    func cargaDelBundle() throws {
        let spots = try JSONLoader.cargarSpots()

        #expect((8...10).contains(spots.count))
        #expect(Set(spots.map(\.id)).count == spots.count)
    }

    @Test("El JSON convierte UUID, fechas ISO 8601 y direcciones web")
    func decodificaTiposNativos() throws {
        let json = """
        {
          "id": "A1B2C3D4-E5F6-7890-ABCD-EF1234567890",
          "title": "Mercado de Verónicas",
          "description": "Mercado de abastos de Murcia.",
          "category": "Mercado",
          "rating": 4.8,
          "visitCount": 120,
          "isFavorite": false,
          "createdAt": "2024-03-15T10:30:00Z",
          "tags": ["Barroco"],
          "imageURL": ["https://example.com/catedral.jpg"],
          "mainImageURL": "https://example.com/catedral-mini.jpg",
          "webURL": "https://www.diocesisdecartagena.org/",
          "latitude": 37.984,
          "longitude": -1.129,
          "reviews": [
            {
              "autor": "Lucía",
              "date": "2024-03-16T10:30:00Z",
              "comment": "Una fachada que merece una visita.",
              "points": 5
            }
          ]
        }
        """
        let spot = try JSONLoader.decodificar(Spot.self, de: Data(json.utf8))
        let date = try #require(ISO8601DateFormatter().date(from: "2024-03-15T10:30:00Z"))
        let review = try #require(spot.reviews.first)

        #expect(spot.id.uuidString == "A1B2C3D4-E5F6-7890-ABCD-EF1234567890")
        #expect(spot.createdAt == date)
        #expect(spot.webURL?.absoluteString == "https://www.diocesisdecartagena.org/")
        #expect(spot.mainImageURL.absoluteString == "https://example.com/catedral-mini.jpg")
        #expect(spot.imageURL.first?.absoluteString == "https://example.com/catedral.jpg")
        #expect(review.author == "Lucía")
        #expect(review.date == date.addingTimeInterval(86_400))
    }

    @Test("Un JSON mal formado lanza un error de decodificación")
    func rechazaJSONMalFormado() {
        let datos = Data(#"[{ "title": 42 "#.utf8)

        #expect(throws: DecodingError.self) {
            try JSONLoader.decodificar([Spot].self, de: datos)
        }
    }

    @Test("Los datos del catálogo cumplen las restricciones del enunciado")
    func datosDelCatalogoValidos() throws {
        let spots = try JSONLoader.cargarSpots()

        #expect(Set(spots.map(\.id)).count == spots.count)
        for spot in spots {
            #expect((1.0...5.0).contains(spot.rating), "Valoración fuera de rango en \(spot.title)")
            #expect((-90.0...90.0).contains(spot.latitude) && (-180.0...180.0).contains(spot.longitude))
            #expect(!spot.imageURL.isEmpty, "\(spot.title) necesita al menos una imagen")
            #expect(spot.reviews.allSatisfy { (1...5).contains($0.points) })
            #expect(spot.directionsURL != nil)
        }
    }

    @Test("Los filtros combinan categoría, favoritos, búsqueda y orden")
    func filtrosDeLaLista() throws {
        let spots = try JSONLoader.cargarSpots()
        let primero = try #require(spots.first)

        let museos = SpotFilter(category: .museum).apply(to: spots, favorites: [])
        #expect(!museos.isEmpty)
        #expect(museos.allSatisfy { $0.category == .museum })

        let favoritos = SpotFilter(onlyFavorites: true).apply(to: spots, favorites: [primero.id])
        #expect(favoritos.map(\.id) == [primero.id])

        let busqueda = SpotFilter(searchText: "VERONICAS").apply(to: spots, favorites: [])
        #expect(busqueda.map(\.title) == ["Mercado de Verónicas"])

        let porPlato = SpotFilter(searchText: "Torpedo").apply(to: spots, favorites: [])
        #expect(porPlato.map(\.title) == ["Pepico del Tío Ginés"])

        let porPastel = SpotFilter(searchText: "pastel de carne").apply(to: spots, favorites: [])
        #expect(porPastel.map(\.title) == ["Pastelería Bonache"])

        let porNota = SpotFilter(sort: .rating).apply(to: spots, favorites: [])
        #expect(porNota.map(\.rating) == porNota.map(\.rating).sorted(by: >))
    }

    @MainActor
    @Test("Los favoritos se guardan y se recuperan")
    func favoritosPersistentes() throws {
        let suite = "UrbanExplorerTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defer { defaults.removePersistentDomain(forName: suite) }
        let spots = try JSONLoader.cargarSpots()
        let lugar = try #require(spots.first)

        let almacen = FavoritesStore(seed: spots, defaults: defaults)
        #expect(!almacen.contains(lugar))
        almacen.toggle(lugar)
        #expect(almacen.contains(lugar))

        let reabierto = FavoritesStore(seed: spots, defaults: defaults)
        #expect(reabierto.contains(lugar))
        reabierto.toggle(lugar)
        #expect(!reabierto.contains(lugar))
    }

    @Test("Un lugar sin web oficial se decodifica y su ruta apunta a Mapas")
    func lugarSinWebYConRuta() throws {
        let json = """
        {
          "id": "A1B2C3D4-E5F6-7890-ABCD-EF1234567890",
          "title": "Pastelería de ejemplo",
          "description": "Sin web propia.",
          "category": "Dulces",
          "rating": 4.5,
          "visitCount": 10,
          "isFavorite": false,
          "createdAt": "2024-03-15T10:30:00Z",
          "tags": [],
          "imageURL": ["https://example.com/foto.jpg"],
          "mainImageURL": "https://example.com/foto-mini.jpg",
          "latitude": 37.98486,
          "longitude": -1.13318,
          "reviews": []
        }
        """
        let spot = try JSONLoader.decodificar(Spot.self, de: Data(json.utf8))
        let ruta = try #require(spot.directionsURL)

        #expect(spot.webURL == nil)
        #expect(ruta.host() == "maps.apple.com")
        #expect(ruta.absoluteString.contains("daddr=37.98486,-1.13318"))
    }
}
