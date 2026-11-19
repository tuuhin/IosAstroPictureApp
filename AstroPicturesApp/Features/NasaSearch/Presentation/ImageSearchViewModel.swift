import Foundation
import Observation

@Observable
@MainActor
final class ImageSearchViewModel {
    private let repository: NasaImageSearchRepository

    init(repository: NasaImageSearchRepository? = nil) {
        self.repository = repository ?? AppDependencyContainer.shared.searchRepository
    }

    private(set) var state: PagedResult<NasaImageSearchResultModel, Error> = .data(
        [], hasMore: false)
    private(set) var errorMessage: String?
    private(set) var totalHits = 0

    /// The trimmed text the current results belong to; `nil` once cleared.
    private(set) var activeQuery: String?

    private var currentPage = 0
    private var hasReachedEnd = false
    private var isLoadingMore = false

    /// Bumped by every new search and by `clear()`, so a response that arrives
    /// after the user typed again is dropped instead of overwriting newer
    /// state.
    private var generation = 0

    var isIdle: Bool { activeQuery == nil }

    var hasResults: Bool { !state.items.isEmpty }

    // MARK: - Searching

    func search(_ raw: String, force: Bool = false) async {
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !text.isEmpty else {
            clear()
            return
        }

        // The typing debounce and an explicit submit can both fire for the
        // same text; only the first should cost a request.
        guard force || text != activeQuery else { return }

        generation += 1
        let token = generation

        activeQuery = text
        currentPage = 0
        hasReachedEnd = false
        isLoadingMore = false
        errorMessage = nil
        totalHits = 0
        state = .loading

        do {
            let page = try await repository.search(Self.makeQuery(text, page: 1))
            guard token == generation else { return }

            apply(page, appendingTo: [])
            currentPage = 1
        }
        catch {
            guard token == generation else { return }

            errorMessage = error.localizedDescription
            state = .error(error)
        }
    }

    func loadNextPageIfNeeded(currentItem item: NasaImageSearchResultModel) async {
        guard !isLoadingMore, !hasReachedEnd, let query = activeQuery else { return }

        let currentItems: [NasaImageSearchResultModel]
        let canLoadMore: Bool

        switch state {
        case let .data(items, hasMore):
            currentItems = items
            canLoadMore = hasMore
        case let .dataError(items, _, hasMore):
            currentItems = items
            canLoadMore = hasMore
        case .loading, .error, .dataLoadingMore:
            return
        }

        guard canLoadMore else {
            hasReachedEnd = true
            return
        }

        // Only trigger when reaching the trailing item.
        guard currentItems.last?.id == item.id else { return }

        isLoadingMore = true
        state = .dataLoadingMore(currentItems)
        defer { isLoadingMore = false }

        let nextPage = currentPage + 1
        let token = generation

        do {
            let page = try await repository.search(Self.makeQuery(query, page: nextPage))
            guard token == generation else { return }

            if !page.results.isEmpty {
                currentPage = nextPage
            }
            apply(page, appendingTo: currentItems)
        }
        catch {
            guard token == generation else { return }

            errorMessage = error.localizedDescription
            state = .dataError(currentItems, error: error, hasMore: true)
        }
    }

    func refresh() async {
        guard let activeQuery else { return }
        await search(activeQuery, force: true)
    }

    /// Drops the results and invalidates any request still in flight.
    func clear() {
        generation += 1
        activeQuery = nil
        currentPage = 0
        hasReachedEnd = false
        isLoadingMore = false
        errorMessage = nil
        totalHits = 0
        state = .data([], hasMore: false)
    }

    // MARK: - State

    private func apply(
        _ page: NasaImageSearchPage,
        appendingTo existing: [NasaImageSearchResultModel]
    ) {
        totalHits = page.totalHits

        let items = Self.deduplicated(existing + page.results)
        let hasMore = page.hasMore && !page.results.isEmpty

        hasReachedEnd = !hasMore
        errorMessage = nil
        state = .data(items, hasMore: hasMore)
    }

    private static func deduplicated(
        _ models: [NasaImageSearchResultModel]
    ) -> [NasaImageSearchResultModel] {
        var seen = Set<String>()
        return models.filter { seen.insert($0.nasaId).inserted }
    }

    private static func makeQuery(_ text: String, page: Int) -> NasaImageSearchQuery {
        var query = NasaImageSearchQuery(text: text)
        query.page = page
        query.pageSize = pageSize
        // Images only: video and audio hits have no still frame to show, so
        // they would render as empty placeholder tiles.
        query.mediaTypes = [.image]
        return query
    }

    private static let pageSize = 30
}
