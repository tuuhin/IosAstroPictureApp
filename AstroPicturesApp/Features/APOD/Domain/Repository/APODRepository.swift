import Foundation

protocol APODRepository: Sendable {
    func fetchLatest() async throws -> AstroPictureModel
    func observeLatest() async throws -> AsyncStream<AstroPictureModel?>
    func toggleFavourite(model: AstroPictureModel) async
}
