import Foundation

struct APIKeyInterceptor: HttpRequestInterceptor {
    func intercept(_ request: URLRequest) async throws -> URLRequest {
        var request = request

        guard var components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }

        var queryItems = components.queryItems ?? []
        guard let apiKey = Bundle.main.infoDictionary?["NASA_API_KEY"] as? String else {
            throw NetworkError.missingApiKey
        }

        queryItems.append(URLQueryItem(name: "api_key", value: apiKey))

        components.queryItems = queryItems
        request.url = components.url
        return request
    }
}
