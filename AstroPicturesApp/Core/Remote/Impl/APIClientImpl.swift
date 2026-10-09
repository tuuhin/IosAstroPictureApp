import Foundation

class APIClientImpl: APIClient {
    private var session: URLSession
    private var baseURL: URL
    private var decoder: JSONDecoder
    private var interceptors: [HttpRequestInterceptor]

    init(session: URLSession, baseURL: URL, decoder: JSONDecoder, interceptors: [HttpRequestInterceptor]) {
        self.session = session
        self.baseURL = baseURL
        self.decoder = decoder
        self.interceptors = interceptors
    }

    func get<T: Decodable & Sendable>(_: T.Type, path: String, params: [URLQueryItem] = []) async throws -> T {
        // prepare the url components
        guard var components = URLComponents(url: baseURL.appending(path: path), resolvingAgainstBaseURL: false) else {
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

        guard let httpResponse = response as? HTTPURLResponse else { throw NetworkError.invalidResponse }

        let remainingHeader = httpResponse.value(forHTTPHeaderField: "X-RateLimit-Remaining") ?? "0"
        let limitHeader = httpResponse.value(forHTTPHeaderField: "X-RateLimit-Limit")

        guard let remainingLimit = Int32(remainingHeader), remainingLimit > 0 else {
            let totalLimit = limitHeader.flatMap { Int($0) } ?? 0
            throw NetworkError.excededLimit(totalLimit: totalLimit)
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}
