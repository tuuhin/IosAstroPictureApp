import Foundation

protocol HttpRequestInterceptor {
    func intercept(_ request: URLRequest) async throws -> URLRequest
}
