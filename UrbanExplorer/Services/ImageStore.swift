import OSLog
import SwiftUI
import UIKit

private let logger = Logger(subsystem: "com.guillermogarcia.ABocados", category: "ImageStore")

/// Caché en memoria de las fotos remotas. Se precarga durante la animación de entrada.
@MainActor
@Observable
final class ImageStore {
    private var images: [URL: UIImage] = [:]
    private var downloads: [URL: Task<UIImage?, Never>] = [:]

    func image(for url: URL) -> UIImage? {
        images[url]
    }

    func preload(_ urls: [URL]) async {
        await withTaskGroup(of: Void.self) { group in
            for url in Set(urls) {
                group.addTask { await self.load(url) }
            }
        }
    }

    func load(_ url: URL) async {
        if images[url] != nil { return }

        // Evita descargar dos veces la misma foto.
        if let running = downloads[url] {
            _ = await running.value
            return
        }

        let download = Task { await Self.download(url) }
        downloads[url] = download
        let image = await download.value
        downloads[url] = nil

        if let image {
            images[url] = image
        }
    }

    nonisolated private static func download(_ url: URL) async -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard (response as? HTTPURLResponse)?.statusCode == 200,
                  let image = UIImage(data: data) else {
                logger.error("Respuesta no válida para \(url.absoluteString, privacy: .public)")
                return nil
            }
            return await image.byPreparingForDisplay() ?? image
        } catch {
            logger.error("No se pudo descargar \(url.absoluteString, privacy: .public): \(error.localizedDescription)")
            return nil
        }
    }
}
