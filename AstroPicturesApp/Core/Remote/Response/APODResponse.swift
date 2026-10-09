import Foundation

struct APODResponse: Decodable, Sendable {
    let date: Date
    let postId: Int64
    let title: String
    let mediaType: APODResponseType
    let description: String
    let credit: String?
    let copyRight: String?
    let alt: String?
    let url: URL
    let hdURL: URL?

    nonisolated init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: APODCodingKeys.self)
        date = try container.decode(Date.self, forKey: .date)
        postId = try container.decodeIfPresent(Int64.self, forKey: .postId) ?? 0
        title = try container.decode(String.self, forKey: .title)
        mediaType = try container.decode(APODResponseType.self, forKey: .mediaType)
        description = try container.decode(String.self, forKey: .description)
        url = try container.decode(URL.self, forKey: .url)
        credit = try container.decodeIfPresent(String.self, forKey: .credit) ?? ""
        copyRight = try container.decodeIfPresent(String.self, forKey: .copyRight) ?? ""
        alt = try container.decodeIfPresent(String.self, forKey: .alt) ?? ""
        hdURL = try container.decodeIfPresent(URL.self, forKey: .hdURL)
    }

    private enum APODCodingKeys: String, CodingKey {
        case date
        case postId = "post_id"
        case title
        case mediaType = "media_type"
        case description = "explaination"
        case credit
        case copyRight = "copyright"
        case alt
        case url
        case hdURL = "hdurl"
    }

    enum APODResponseType: String, Decodable, Sendable {
        case video
        case image
    }
}
