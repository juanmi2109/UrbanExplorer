import Foundation
import OSLog

private let logger = Logger(subsystem: "com.guillermogarcia.ABocados", category: "JSONLoader")

enum JSONLoader {
    private enum LoadingError: LocalizedError {
        case recursoAusente

        var errorDescription: String? {
            "No se encuentra spots.json en el Bundle."
        }
    }

    static func cargarSpots() throws -> [Spot] {
        guard let url = Bundle.main.url(forResource: "spots", withExtension: "json") else {
            throw LoadingError.recursoAusente
        }
        return try decodificar([Spot].self, de: Data(contentsOf: url))
    }

    static func decodificar<T: Decodable>(_ tipo: T.Type, de datos: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(tipo, from: datos)
    }

    /// Versión para la app: si algo falla, registra el motivo y devuelve una lista vacía.
    static func cargarSpotsParaLaApp() -> [Spot] {
        do {
            return try cargarSpots()
        } catch DecodingError.keyNotFound(let clave, let contexto) {
            let lugar = ruta(contexto)
            logger.error("Falta la clave '\(clave.stringValue)' en \(lugar)")
        } catch DecodingError.typeMismatch(let tipo, let contexto) {
            let lugar = ruta(contexto)
            logger.error("Se esperaba \(String(describing: tipo)) en \(lugar)")
        } catch DecodingError.valueNotFound(let tipo, let contexto) {
            let lugar = ruta(contexto)
            logger.error("Falta un valor de tipo \(String(describing: tipo)) en \(lugar)")
        } catch DecodingError.dataCorrupted(let contexto) {
            let lugar = ruta(contexto)
            logger.error("Datos no válidos en \(lugar): \(contexto.debugDescription)")
        } catch {
            logger.error("\(error.localizedDescription)")
        }
        return []
    }

    private static func ruta(_ contexto: DecodingError.Context) -> String {
        let claves = contexto.codingPath.map { clave in
            clave.intValue.map { "[\($0)]" } ?? clave.stringValue
        }
        return (["raíz"] + claves).joined(separator: ".")
    }
}
