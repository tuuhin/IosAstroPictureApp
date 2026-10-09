import Foundation

@MainActor
final class AppDependencyContainer {
    static let shared = AppDependencyContainer()

    let apiClient: APIClient
    let apodRemoteDataSource: APODRemoteDataSource
    let apodRepository: APODRepository

    init(baseURL: URL = URL(string: "https://api.nasa.gov")!) {
        let interceptors: [HttpRequestInterceptor] = [APIKeyInterceptor()]
        let client = APIClientImpl(
            session: NetworkingConfiguration.session,
            baseURL: baseURL,
            decoder: NetworkingConfiguration.decoder,
            interceptors: interceptors
        )
        apiClient = client
        let remoteDataSource = APODRemoteDataSourceImpl(client: client)
        apodRemoteDataSource = remoteDataSource
        apodRepository = APODRepositoryImpl(remoteDataSource: remoteDataSource)
    }
}
