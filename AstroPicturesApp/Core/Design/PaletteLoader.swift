import Foundation
import PaletteKit

/// Loads and caches the palette for a remote image.
///
/// Shared by the detail background and the ambient glow so each image is only
/// downloaded and quantized once, no matter how many places sample it.
actor PaletteLoader {
    static let shared = PaletteLoader()

    private var storage: [URL: Palette] = [:]

    /// Returns the cached palette for `url`, extracting it on first use.
    /// Pass `nil` (e.g. for videos) to get `nil` without any work.
    func palette(for url: URL?) async -> Palette? {
        guard let url else { return nil }
        if let cached = storage[url] { return cached }

        // PaletteKit's `.url` source only reads file URLs, so fetch the bytes first.
        guard let (data, _) = try? await URLSession.shared.data(from: url),
            let extracted = try? await PaletteExtractor().palette(from: .data(data))
        else {
            return nil
        }

        storage[url] = extracted
        return extracted
    }
}
