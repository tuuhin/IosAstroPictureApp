import Foundation

final class APODRepositoryImpl: APODRepository {
    private let remoteDataSource: AstroPictureRemoteDataSource
    private let localDataSource: AstroPictureLocalDataSource

    init(
        remoteDataSource: AstroPictureRemoteDataSource,
        localDataSource: AstroPictureLocalDataSource
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    func fetchLatest() async throws -> AstroPictureModel {
        do {
            // Try loading from local storage first
            return try await localDataSource.fetchLatest()
        }
        catch LocalDbErrors.entryAbsent {
            // Fall back to remote source if missing locally
            let remoteResult = try await remoteDataSource.fetchSingleImage()
            // Persist to cache and return directly
            try await localDataSource.save(remoteResult)
            // fallback to the latest image
            return try await localDataSource.fetchLatest()
        }
    }

    func observeLatest() async throws -> AsyncStream<AstroPictureModel?> {
        // a fetch latest call to update the db
        _ = try await fetchLatest()
        // then observe the db
        return try await localDataSource.observeLatest()
    }

    func toggleFavourite(model: AstroPictureModel) async {
        var mutableModel = model
        mutableModel.isFav.toggle()
        try? await localDataSource.save(mutableModel)
    }
}
