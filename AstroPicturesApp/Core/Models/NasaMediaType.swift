import Foundation

/// Media types returned by the images.nasa.gov search API.
///
/// This is deliberately separate from ``APODMediaType``: APOD only ever serves
/// images and videos, while the image library also indexes audio.
enum NasaMediaType: String, Sendable, Hashable, CaseIterable {
    case image
    case video
    case audio
    /// Anything the API returns that we don't model yet.
    case other

    /// The value the search API expects in `media_type`; `nil` for ``other``
    /// because it is a client-side fallback, not a real API value.
    var apiValue: String? {
        self == .other ? nil : rawValue
    }
}
