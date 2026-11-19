import Foundation

typealias DecodableSendable = Decodable & Sendable

protocol APIClient {
    func get<T: DecodableSendable>(_ type: T.Type, path: String, params: [URLQueryItem])
        async throws -> APIResponse<T>
}
