import Foundation
import SwiftData

@MainActor
final class AppDependencyContainer {

    static let shared = AppDependencyContainer()

    let apodRemoteDataSource: AstroPictureRemoteDataSource
    let apodLocalDao: AstroPictureLocalDataSource
    let apodRepository: APODRepository
    let exploreRepository: ExploreRepository
    let searchRemoteDataSource: NasaImageSearchRemoteDataSource
    let searchRepository: NasaImageSearchRepository

    private let nasaURL = URL(string: "https://science.nasa.gov")

    /// The image library lives on its own host and does not use an API key.
    private let nasaImagesURL = URL(string: "https://images-api.nasa.gov")

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
        apodRepository = APODRepositoryImpl(
            remoteDataSource: remoteDataSource, localDataSource: apodLocalDao)

        // set the explore repository
        exploreRepository = ExploreRepositoryImpl(
            remoteDataSource: remoteDataSource, localDataSource: apodLocalDao)

        // search talks to images-api.nasa.gov: separate host, no API key
        // interceptor, and no local store
        let searchClient = APIClientImpl(
            session: NetworkingConfiguration.session,
            baseURL: nasaImagesURL!,
            decoder: NetworkingConfiguration.decoder,
            interceptors: []
        )

        let searchRemote = NasaImageSearchRemoteDataSourceImpl(client: searchClient)
        searchRemoteDataSource = searchRemote
        searchRepository = NasaImageSearchRepositoryImpl(remoteDataSource: searchRemote)
    }
}
