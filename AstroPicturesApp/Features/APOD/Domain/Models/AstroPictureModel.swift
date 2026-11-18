import Foundation

struct AstroPictureModel: Sendable {
    let date: Date
    let postId: Int
    let title: String
    let mediaType: APODMediaType
    let description: String
    let credit: String?
    let copyRight: String?
    let alt: String?
    let url: String
    let hdURL: String?
    var isFav: Bool
}
