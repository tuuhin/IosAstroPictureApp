import Foundation

/// Read-only access to the NASA image library search index.
///
/// Backed by a separate base URL and needs no API key, so it is wired with its
/// own ``APIClient`` rather than the APOD one.
protocol NasaImageSearchRemoteDataSource {
    func search(_ query: NasaImageSearchQuery) async throws -> NasaImageSearchPage
}
