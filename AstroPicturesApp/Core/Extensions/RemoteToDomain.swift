import Foundation

extension APODResponse {
    func toDomainModel() -> AstroPictureModel {
        AstroPictureModel(
            date: date,
            postId: Int(postId),
            title: title,
            mediaType: mediaType == .video ? .video : .image,
            description: description,
            credit: credit,
            copyRight: copyRight,
            alt: alt,
            url: url,
            hdURL: hdURL,
            isFav: false)
    }
}

extension NasaImageSearchResponse {

    /// Maps a Collection+JSON payload into a domain page.
    ///
    /// Paging is driven by `metadata.total_hits` rather than by whether a full
    /// page came back: the API happily returns a partial page in the middle of
    /// a result set.
    func toDomainPage(requestedPage: Int, pageSize: Int) -> NasaImageSearchPage {
        let results = collection.items.compactMap { $0.toDomainModel() }
        let totalHits = collection.metadata?.totalHits ?? 0

        let hasMore: Bool
        if totalHits > 0 {
            hasMore = requestedPage * pageSize < totalHits
        }
        else {
            hasMore = results.count >= pageSize
        }

        return NasaImageSearchPage(
            results: results,
            totalHits: totalHits,
            page: requestedPage,
            hasMore: hasMore
        )
    }
}

extension NasaImageSearchResponse.SearchItem {
    /// Returns `nil` for items without a `nasa_id`, which have no identity and
    /// so cannot be shown or paged against.
    func toDomainModel() -> NasaImageSearchResultModel? {
        guard let entry = data?.first, let rawId = entry.nasaId else { return nil }

        let nasaId = rawId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !nasaId.isEmpty else { return nil }

        let mediaType = entry.mediaType.flatMap(NasaMediaType.init(rawValue:)) ?? .other
        let links = self.links ?? []

        let thumbnail = links.first { $0.rel == "preview" }?.href
        let trimmedTitle = entry.title?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        return NasaImageSearchResultModel(
            nasaId: nasaId,
            title: trimmedTitle.isEmpty ? nasaId : trimmedTitle,
            description: entry.description,
            mediaType: mediaType,
            center: entry.center,
            date: Self.parseDate(entry.dateCreated),
            keywords: entry.keywords ?? [],
            thumbnailURL: Self.url(from: thumbnail)
                ?? Self.assetThumbnailURL(nasaId: nasaId, mediaType: mediaType),
            largeURL: Self.displayURL(from: links),
            manifestURL: Self.url(from: href)
        )
    }

    /// Picks the biggest `alternate` rendition that a UI can actually decode,
    /// falling back to `canonical`. `canonical` is skipped when it is not a web
    /// image (some assets publish a `.tif`), and audio has no links at all.
    private static func displayURL(from links: [NasaImageSearchResponse.SearchLink]) -> URL? {
        let renderable = links.filter { isWebImage($0.href) }

        let alternates =
            renderable
            .filter { $0.rel == "alternate" }
            .max { area($0) < area($1) }

        let canonical = renderable.first { $0.rel == "canonical" }

        return url(from: alternates?.href) ?? url(from: canonical?.href)
    }

    private static func area(_ link: NasaImageSearchResponse.SearchLink) -> Int {
        (link.width ?? 0) * (link.height ?? 0)
    }

    private static func isWebImage(_ href: String?) -> Bool {
        guard let path = href?.lowercased() else { return false }
        return ["jpg", "jpeg", "png", "gif", "webp"].contains { path.hasSuffix(".\($0)") }
    }

    /// Parses the API's `date_created` (`1969-07-21T00:00:00Z`), tolerating a
    /// fractional-seconds variant.
    private static func parseDate(_ raw: String?) -> Date? {
        guard let raw, !raw.isEmpty else { return nil }

        if let date = try? Date(raw, strategy: Date.ISO8601FormatStyle()) {
            return date
        }

        return try? Date(raw, strategy: Date.ISO8601FormatStyle(includingFractionalSeconds: true))
    }

    /// `URL(string:)` rejects the unescaped spaces some assets have in their
    /// `nasa_id`, so fall back to percent-encoding before giving up.
    private static func url(from raw: String?) -> URL? {
        guard let raw else { return nil }

        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if let url = URL(string: trimmed) { return url }

        guard
            let encoded = trimmed.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)
        else { return nil }
        return URL(string: encoded)
    }

    /// Audio assets ship no `links` at all; image and video assets always have
    /// a `~thumb.jpg` next to their manifest, so it can be derived from the id.
    private static func assetThumbnailURL(
        nasaId: String,
        mediaType: NasaMediaType
    ) -> URL? {
        guard mediaType == .image || mediaType == .video else { return nil }

        var allowed = CharacterSet.urlPathAllowed
        allowed.remove(charactersIn: "/")
        guard let encodedId = nasaId.addingPercentEncoding(withAllowedCharacters: allowed)
        else { return nil }

        let type = mediaType.rawValue
        return URL(
            string: "https://images-assets.nasa.gov/\(type)/\(encodedId)/\(encodedId)~thumb.jpg")
    }
}
