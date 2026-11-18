import Foundation

protocol AstroPictureRemoteDataSource {
    func fetchImagesByDate(_ date: Date) async throws -> [AstroPictureModel]
    func fetchSingleImage() async throws -> AstroPictureModel
    func fetchPagesImages(page: Int, pageCount: Int) async throws -> [AstroPictureModel]
    func fetchImageByDateRange(start: Date, end: Date) async throws -> [AstroPictureModel]
}
