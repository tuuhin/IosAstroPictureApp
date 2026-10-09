import Foundation

final class APODRepositoryImpl: APODRepository {
    private let remoteDataSource: APODRemoteDataSource

    init(remoteDataSource: APODRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchToday() async throws -> APODModel {
        try await remoteDataSource.fetchToday()
    }
}
