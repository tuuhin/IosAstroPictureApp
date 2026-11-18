import Foundation

final class AstroPictureRemoteDataSourceImpl: AstroPictureRemoteDataSource {
    private let client: APIClient
    private let formatter: DateFormatter

    init(client: APIClient) {
        self.client = client

        // query strings need a new dateformatter
        formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyMMdd"
    }

    func fetchSingleImage() async throws -> AstroPictureModel {
        let response = try await client.get([APODResponse].self,
                                            path: "wp-json/wp/v2/apod-basic",
                                            params: [URLQueryItem(name: "per_page", value: "1")])

        guard let result = response.first else {
            throw NetworkError.invalidResponse
        }

        return result.toDomainModel()
    }

    func fetchImagesByDate(_ date: Date) async throws -> [AstroPictureModel] {
        let formatted = formatter.string(from: date)

        let response = try await client.get([APODResponse].self,
                                            path: "wp-json/wp/v2/apod-basic",
                                            params: [
                                                URLQueryItem(name: "date_from", value: formatted),
                                                URLQueryItem(name: "date_to", value: formatted),
                                            ])

        return response.map { $0.toDomainModel() }
    }

    func fetchImageByDateRange(start: Date, end: Date) async throws -> [AstroPictureModel] {
        let formatted = formatter.string(from: start)
        let formattedEnd = formatter.string(from: end)

        let params = [
            URLQueryItem(name: "date_from", value: formatted),
            URLQueryItem(name: "date_to", value: formattedEnd),
        ]

        let response = try await client.get([APODResponse].self, path: "wp-json/wp/v2/apod-basic", params: params)
        return response.map { $0.toDomainModel() }
    }

    func fetchPagesImages(page: Int, pageCount: Int) async throws -> [AstroPictureModel] {
        let pageNumber = String(page)
        let noOfitems = String(min(pageCount, 10))

        let response = try await client.get(
            [APODResponse].self,
            path: "wp-json/wp/v2/apod-basic",
            params: [
                URLQueryItem(name: "page", value: pageNumber),
                URLQueryItem(name: "per_page", value: noOfitems),
            ]
        )
        return response.map { $0.toDomainModel() }
    }
}
