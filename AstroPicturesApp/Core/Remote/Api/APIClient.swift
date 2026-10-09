import Foundation

protocol APIClient {
    func get<T: Sendable & Decodable>(_ type: T.Type, path: String, params: [URLQueryItem]) async throws -> T
}
