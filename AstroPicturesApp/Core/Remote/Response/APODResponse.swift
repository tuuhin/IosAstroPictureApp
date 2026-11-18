import Foundation

struct APODResponse: Decodable, Sendable {
    let date: Date
    let postId: Int64
    let title: String
    let permaLink: String?
    let mediaType: APODResponseType?
    let description: String
    let credit: String?
    let copyRight: String?
    let alt: String?
    let url: String
    let hdURL: String?

    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: APODCodingKeys.self)

        date = try container.decode(Date.self, forKey: .date)
        postId = try container.decodeIfPresent(Int64.self, forKey: .postId) ?? 0
        title = try container.decode(String.self, forKey: .title)
        mediaType = try container.decodeIfPresent(APODResponseType.self, forKey: .mediaType)
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        credit = try container.decodeIfPresent(String.self, forKey: .credit)
        copyRight = try container.decodeIfPresent(String.self, forKey: .copyRight)
        alt = try container.decodeIfPresent(String.self, forKey: .alt)
        url = try container.decode(String.self, forKey: .url)
        hdURL = try container.decodeIfPresent(String.self, forKey: .hdURL)
        permaLink = try container.decodeIfPresent(String.self, forKey: .permaLink)
    }

    private enum APODCodingKeys: String, CodingKey {
        case date
        case postId = "post_id"
        case title
        case mediaType = "media_type"
        case description = "explanation"
        case credit
        case copyRight = "copyright"
        case alt
        case url
        case hdURL = "hdurl"
        case permaLink = "permalink"
    }

    enum APODResponseType: String, Decodable, Sendable {
        case video
        case image
        case iframe
        case other

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = APODResponseType(rawValue: rawValue) ?? .other
        }
    }
}
