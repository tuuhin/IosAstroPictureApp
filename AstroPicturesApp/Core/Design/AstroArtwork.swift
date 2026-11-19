import Foundation

/// What a picture-like asset actually is, decoupled from the API that
/// produced it. Both the APOD model and search results map onto this.
enum AstroArtwork: Sendable, Hashable {
    case image(URL?)
    case video
    case audio

    /// The image to load, or `nil` when the asset has no still image.
    var imageURL: URL? {
        if case let .image(url) = self { return url }
        return nil
    }

    /// SF Symbol shown in place of a still image.
    var placeholderSymbol: String {
        switch self {
        case .image:
            return "photo"
        case .video:
            return "play.tv.fill"
        case .audio:
            return "music.note"
        }
    }
}
