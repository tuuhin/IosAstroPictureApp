import Foundation

/// Search is remote-only: results are never written to the local store, so
/// there is no cache to fall back to and no favourite flag to persist.
protocol NasaImageSearchRepository {
    func search(_ query: NasaImageSearchQuery) async throws -> NasaImageSearchPage
}
