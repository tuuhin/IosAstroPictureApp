import Foundation

/// One page of search results, plus the paging metadata the API reports.
struct NasaImageSearchPage: Sendable {
    let results: [NasaImageSearchResultModel]
    /// `collection.metadata.total_hits`; `0` when the API omits it.
    let totalHits: Int
    /// The page this payload was requested for, starting at 1.
    let page: Int
    let hasMore: Bool

    var isEmpty: Bool { results.isEmpty }
}
