import Foundation
import Observation

@Observable
@MainActor
final class ExploreViewModel {
    private let repository: ExploreRepository

    init(repository: ExploreRepository? = nil) {
        self.repository = repository ?? AppDependencyContainer.shared.exploreRepository
    }

    private(set) var state: PagedResult<AstroPictureModel, Error> = .loading
    private(set) var errorMessage: String? = nil
    private(set) var isShowingCache = false

    private var currentPage = 0
    private var hasReachedEnd = false
    private var isLoadingMore = false

    // Load the initial page from remote or cache.
    func loadInitial() async {

        state = .loading
        errorMessage = nil
        currentPage = 0
        hasReachedEnd = false

        do {
            let page = try await repository.fetchPage(1, pageSize: Self.pageSize)
            switch page {
            case .loading:
                state = .loading
                isShowingCache = false
            case let .success(results, _):
                currentPage = 1
                isShowingCache = results.isFromCache
                hasReachedEnd = !results.hasMore || results.models.isEmpty
                state = .data(Self.deduplicated(results.models), hasMore: results.hasMore)

            case let .error(err, message, results):
                let existing = Self.deduplicated(results?.models ?? [])
                let canLoadMore = results?.hasMore ?? false
                errorMessage = message
                hasReachedEnd = !canLoadMore

                if existing.isEmpty {
                    state = .error(err)
                }
                else {
                    currentPage = 1
                    state = .dataError(existing, error: err, hasMore: canLoadMore)
                }
            }
        }
        catch {
            state = .error(error)
            errorMessage = error.localizedDescription
        }
    }

    func loadNextPageIfNeeded(currentItem: AstroPictureModel) async {
        guard !isLoadingMore, !hasReachedEnd else { return }

        let currentItems: [AstroPictureModel]
        let canLoadMore: Bool

        switch state {
        case let .data(models, hasMore):
            currentItems = models
            canLoadMore = hasMore
        case let .dataError(models, _, hasMore):
            currentItems = models
            canLoadMore = hasMore
        case .loading, .error, .dataLoadingMore:
            return
        }

        guard canLoadMore else {
            hasReachedEnd = true
            return
        }

        // Only trigger when reaching the trailing item.
        guard currentItems.last?.postId == currentItem.postId else { return }

        isLoadingMore = true
        state = .dataLoadingMore(currentItems)
        defer { isLoadingMore = false }

        let nextPage = currentPage + 1

        do {
            let page = try await repository.fetchPage(nextPage, pageSize: Self.pageSize)
            switch page {
            case .loading:
                break

            case let .success(results, _):
                isShowingCache = results.isFromCache
                errorMessage = nil

                // `hasMore` comes from the raw page response, independent of deduplication.
                let nextHasMore = results.hasMore && !results.models.isEmpty
                hasReachedEnd = !nextHasMore

                let merged = Self.deduplicated(currentItems + results.models)
                if !results.models.isEmpty {
                    currentPage = nextPage
                }
                state = .data(merged, hasMore: nextHasMore)

            case let .error(err, message, _):
                errorMessage = message
                state = .dataError(currentItems, error: err, hasMore: true)
            }
        }
        catch {
            errorMessage = error.localizedDescription
            state = .dataError(currentItems, error: error, hasMore: true)
        }
    }

    func refresh() async {
        await loadInitial()
    }

    func toggleFavourite(_ picture: AstroPictureModel) async {
        await repository.toggleFavourite(model: picture)
    }

    private static func deduplicated(_ models: [AstroPictureModel]) -> [AstroPictureModel] {
        var seen = Set<Int>()
        return models.filter { seen.insert($0.postId).inserted }
    }

    private static let pageSize = 10
}
