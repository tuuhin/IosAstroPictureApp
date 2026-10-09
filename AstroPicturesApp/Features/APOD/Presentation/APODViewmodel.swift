import Foundation
import Observation

enum ViewState {
    case idle
    case loading
    case success(APODModel)
    case failure(Error)
}

@Observable
@MainActor
final class APODViewModel {
    /// injections
    private let repository: APODRepository

    var state: ViewState = .idle

    init(repository: APODRepository = AppDependencyContainer.shared.apodRepository) {
        self.repository = repository
    }

    func fetchToday() async {
        state = .loading
        do {
            let apod = try await repository.fetchToday()
            state = .success(apod)
        } catch {
            state = .failure(error)
        }
    }
}
