import Foundation
import SwiftData

@MainActor
final class AppDependencyContainer {
    static let shared = AppDependencyContainer()

    let apodRemoteDataSource: AstroPictureRemoteDataSource
    let apodLocalDao: AstroPictureLocalDataSource
    let apodRepository: APODRepository

    private let nasaURL = URL(string: "https://science.nasa.gov")

    init() {
        let interceptors: [HttpRequestInterceptor] = [APIKeyInterceptor()]

        // client
        let client = APIClientImpl(
            session: NetworkingConfiguration.session,
            baseURL: nasaURL!,
            decoder: NetworkingConfiguration.decoder,
            interceptors: interceptors
        )

        // remote client
        let remoteDataSource = AstroPictureRemoteDataSourceImpl(client: client)
        apodRemoteDataSource = remoteDataSource

        // local source
        let modelContainer = LocalDbConfig.dbModelContainer
        apodLocalDao = AstroPictureLocalDataSourceImpl(context: modelContainer.mainContext)

        // set the apod repository
        apodRepository = APODRepositoryImpl(remoteDataSource: remoteDataSource, localDataSource: apodLocalDao)
    }
}
