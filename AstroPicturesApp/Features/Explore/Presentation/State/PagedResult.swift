enum PagedResult<D, E: Error> {
    case loading
    case data([D], hasMore: Bool = true)
    case error(E)
    case dataLoadingMore([D])
    case dataError([D], error: E, hasMore: Bool = true)
}

extension PagedResult {

    var items: [D] {
        switch self {
        case .loading, .error:
            return []
        case let .data(items, _),
            let .dataLoadingMore(items),
            let .dataError(items, _, _):
            return items
        }
    }

    var isLoadingInitial: Bool {
        if case .loading = self { return true }
        return false
    }

    var isLoadingMore: Bool {
        if case .dataLoadingMore = self { return true }
        return false
    }

    var canLoadMore: Bool {
        switch self {
        case let .data(_, hasMore):
            return hasMore
        case let .dataError(_, _, hasMore):
            return hasMore
        case .loading, .error, .dataLoadingMore:
            return false
        }
    }

    var failure: E? {
        switch self {
        case let .error(error), let .dataError(_, error, _):
            return error
        case .loading, .data, .dataLoadingMore:
            return nil
        }
    }
}
