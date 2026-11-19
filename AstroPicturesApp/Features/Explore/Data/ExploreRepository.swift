import Foundation

protocol ExploreRepository: Sendable {
    func fetchPage(_ page: Int, pageSize: Int) async throws -> Resource<
        PagedAstroPicturesModel, Error
    >
    func toggleFavourite(model: AstroPictureModel) async
}
