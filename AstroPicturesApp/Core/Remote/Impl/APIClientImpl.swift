import Foundation

final class APIClientImpl: APIClient {

    private var session: URLSession
    private var baseURL: URL
    private var decoder: JSONDecoder
    private var interceptors: [HttpRequestInterceptor]

    init(
        session: URLSession,
        baseURL: URL,
        decoder: JSONDecoder = NetworkingConfiguration.decoder,
        interceptors: [HttpRequestInterceptor] = []
    ) {
        self.session = session
        self.baseURL = baseURL
        self.decoder = decoder
        self.interceptors = interceptors
    }

    func get<T: DecodableSendable>(_: T.Type, path: String, params: [URLQueryItem] = [])
        async throws -> APIResponse<T>
    {

        // prepare the url components
        guard
            var components = URLComponents(
                url: baseURL.appending(path: path), resolvingAgainstBaseURL: false)
        else {
            throw NetworkError.invalidURL
        }

        // adds any query params
        components.queryItems = params.isEmpty ? nil : params

        // build the final url
        guard let finalUrl = components.url else { throw NetworkError.invalidURL }

        // prepare the request
        var request = URLRequest(url: finalUrl)
        request.httpMethod = "GET"

        // add inteceptors
        for interceptor in interceptors {
            request = try await interceptor.intercept(request)
        }

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        do {
            let value = try decoder.decode(T.self, from: data)
            return APIResponse(
                value: value, statusCode: httpResponse.statusCode,
                headers: httpResponse.headersMap())
        }
        catch {
            throw NetworkError.decodingFailed(error)
        }
    }

}

extension HTTPURLResponse {

    fileprivate func headersMap() -> [String: String] {
        var finalMap: [String: String] = [:]

        for (k, v) in allHeaderFields {
            let key = String(describing: k).lowercased()
            let value = String(describing: v)
            finalMap[key] = value
        }

        return finalMap
    }
}
