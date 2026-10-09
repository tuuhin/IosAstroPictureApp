import Foundation

protocol APODRepository: Sendable {
    func fetchToday() async throws -> APODModel
}
