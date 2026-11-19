import Foundation

/// A single hit from the images.nasa.gov search API.
///
/// Unlike ``AstroPictureModel`` this type has no `postId` and no favourite
/// flag: the image library identifies assets by `nasa_id` and search results
/// are never persisted, so there is nothing to key a local record on.
struct NasaImageSearchResultModel: Sendable, Hashable, Identifiable {
    /// The asset's NASA ID, e.g. `as11-40-5874`.
    let nasaId: String
    let title: String
    /// Plain-text description. The API omits it on a small number of assets.
    let description: String?
    let mediaType: NasaMediaType
    let center: String?
    let date: Date?
    let keywords: [String]
    /// The `preview` link (a `~thumb.jpg`), or an asset-path fallback.
    let thumbnailURL: URL?
    /// The largest web-renderable rendition, for the detail screen. Picked from
    /// the `alternate` links because an image's `canonical` link is sometimes a
    /// `.tif` (or, for video, missing entirely).
    let largeURL: URL?
    /// The asset's `collection.json` manifest, the entry point for its full
    /// rendition list — how a video's playable file is found.
    let manifestURL: URL?

    var id: String { nasaId }
}
