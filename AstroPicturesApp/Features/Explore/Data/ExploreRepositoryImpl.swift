import Foundation

final class ExploreRepositoryImpl: ExploreRepository {

    private let remoteDataSource: AstroPictureRemoteDataSource
    private let localDataSource: AstroPictureLocalDataSource

    init(
        remoteDataSource: AstroPictureRemoteDataSource,
        localDataSource: AstroPictureLocalDataSource
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    func fetchPage(_ page: Int, pageSize: Int) async throws -> Resource<
        PagedAstroPicturesModel, Error
    > {
        do {
            // fetch the results first
            let result = try await remoteDataSource.fetchPagesImages(
                page: page, pageCount: pageSize)

            // save the results in db
            try? await localDataSource.saveMultiple(result.pictures)

            // return a pages response
            let pagedResult = PagedAstroPicturesModel(
                models: result.pictures,
                hasMore: Self.hasMore(result, page: page, pageSize: pageSize),
                isFromCache: false
            )

            return .success(data: pagedResult, message: "Content loaded successfully")

        }
        catch {
            // in case we failed to load from the internet load it from cache
            guard let cached = try? await localDataSource.fetchPage(page: page, pageSize: pageSize)
            else {
                // if no cache no cache found
                return .error(error: error, message: "No cached data found", data: nil)
            }
            let pagedResult = PagedAstroPicturesModel(
                models: cached,
                hasMore: false,
                isFromCache: true
            )
            // mention load failed with message
            return .error(error: error, message: "Failed to load data", data: pagedResult)
        }
    }

    func toggleFavourite(model: AstroPictureModel) async {
        var mutableModel = model
        mutableModel.isFav.toggle()
        try? await localDataSource.save(mutableModel)
    }

    private static func hasMore(_ result: AstroPicturePage, page: Int, pageSize: Int) -> Bool {
        if result.totalPages > 0 {
            return page < result.totalPages
        }
        return result.pictures.count == pageSize
    }

}
