import Foundation

/// A `GET https://images-api.nasa.gov/search` request.
///
/// Every parameter maps 1:1 to the documented query string; omitted values are
/// simply left out of the request. `page` starts at 1.
struct NasaImageSearchQuery: Sendable {
    /// Free-text search across all indexed metadata (`q`).
    var text: String?
    var title: String?
    var description: String?
    var keywords: [String] = []
    var location: String?
    var center: String?
    var nasaId: String?
    var mediaTypes: [NasaMediaType] = []
    var yearStart: Int?
    var yearEnd: Int?
    var photographer: String?
    var secondaryCreator: String?
    var page: Int = 1
    var pageSize: Int = NasaImageSearchQuery.defaultPageSize

    static let defaultPageSize = 50
    /// Documented maximum (`page_size` defaults to 100 server side).
    static let maximumPageSize = 100

    var clampedPage: Int { max(page, 1) }

    var clampedPageSize: Int { min(max(pageSize, 1), Self.maximumPageSize) }

    var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []

        func add(_ name: String, _ value: String?) {
            guard let value, !value.isEmpty else { return }
            items.append(URLQueryItem(name: name, value: value))
        }

        add("q", text)
        add("title", title)
        add("description", description)
        add("keywords", keywords.isEmpty ? nil : keywords.joined(separator: ","))
        add("location", location)
        add("center", center)
        add("nasa_id", nasaId)
        add("media_type", mediaTypeParameter)
        add("year_start", yearStart.map(String.init))
        add("year_end", yearEnd.map(String.init))
        add("photographer", photographer)
        add("secondary_creator", secondaryCreator)
        add("page", String(clampedPage))
        add("page_size", String(clampedPageSize))

        return items
    }

    private var mediaTypeParameter: String? {
        let values = mediaTypes.compactMap(\.apiValue)
        return values.isEmpty ? nil : values.joined(separator: ",")
    }
}
