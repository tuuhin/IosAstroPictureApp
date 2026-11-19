import Foundation

final class NasaImageSearchRepositoryImpl: NasaImageSearchRepository {

    private let remoteDataSource: NasaImageSearchRemoteDataSource

    init(remoteDataSource: NasaImageSearchRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func search(_ query: NasaImageSearchQuery) async throws -> NasaImageSearchPage {
        try await remoteDataSource.search(query)
    }
}
