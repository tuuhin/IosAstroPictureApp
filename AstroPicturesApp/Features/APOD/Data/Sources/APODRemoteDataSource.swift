import Foundation

protocol APODRemoteDataSource {
    func fetchToday() async throws -> APODModel
}

class APODRemoteDataSourceImpl: APODRemoteDataSource {
    let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func fetchToday() async throws -> APODModel {
        let response = try await client.get([APODResponse].self,
                                            path: "wp-json/wp/v2/apod-basic",
                                            params: [URLQueryItem(name: "count", value: "1")])

        guard let result = response.first else {
            throw GeneralErrors.missingData
        }

        return result.toDomainModel()
    }
}
