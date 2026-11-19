import Foundation

final class NasaImageSearchRemoteDataSourceImpl: NasaImageSearchRemoteDataSource {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func search(_ query: NasaImageSearchQuery) async throws -> NasaImageSearchPage {
        let response = try await client.get(
            NasaImageSearchResponse.self,
            path: "search",
            params: query.queryItems
        )

        return response.value.toDomainPage(
            requestedPage: query.clampedPage,
            pageSize: query.clampedPageSize
        )
    }
}
