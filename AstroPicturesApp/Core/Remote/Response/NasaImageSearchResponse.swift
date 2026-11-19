import Foundation

/// The Collection+JSON envelope returned by `GET /search`.
///
/// Decoding is deliberately tolerant: the API omits `description` on a few
/// assets and returns no `links` at all for audio, so every value except the
/// envelope itself is optional and invalid items are dropped during mapping.
nonisolated struct NasaImageSearchResponse: Decodable, Sendable {
    let collection: SearchCollection

    nonisolated struct SearchCollection: Decodable, Sendable {
        let items: [SearchItem]
        let metadata: SearchMetadata?
    }

    nonisolated struct SearchItem: Decodable, Sendable {
        let href: String?
        let data: [SearchItemData]?
        let links: [SearchLink]?
    }

    nonisolated struct SearchItemData: Decodable, Sendable {
        let nasaId: String?
        let title: String?
        let description: String?
        let mediaType: String?
        let center: String?
        let dateCreated: String?
        let keywords: [String]?

        private enum CodingKeys: String, CodingKey {
            case nasaId = "nasa_id"
            case title
            case description
            case mediaType = "media_type"
            case center
            case dateCreated = "date_created"
            case keywords
        }
    }

    nonisolated struct SearchLink: Decodable, Sendable {
        let href: String?
        let rel: String?
        let render: String?
        let width: Int?
        let height: Int?
    }

    nonisolated struct SearchMetadata: Decodable, Sendable {
        let totalHits: Int?

        private enum CodingKeys: String, CodingKey {
            case totalHits = "total_hits"
        }
    }
}
