import Foundation

enum NetworkError: Error {
    case invalidURL
    case missingApiKey
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingFailed(Error)
    case excededLimit(totalLimit: Int?)
}
