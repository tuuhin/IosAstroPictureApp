import Foundation
import Observation

@Observable
@MainActor
final class APODViewModel {
    private let repository: APODRepository

    init(repository: APODRepository? = nil) {
        // using the apod repository from the dependency container
        self.repository = repository ?? AppDependencyContainer.shared.apodRepository
    }

    var state: APODScreenState = .idle

    func observe() async {
        do {
            // read in the async stream
            for await latest in try await repository.observeLatest() {
                if let latest {
                    state = .success(latest)
                }
            }
        }
        catch {
            state = .failure(error)
        }
    }

    func toggleFavourite() async {
        if case .success(let astroPictureModel) = state {
            await repository.toggleFavourite(model: astroPictureModel)
        }
    }
}
