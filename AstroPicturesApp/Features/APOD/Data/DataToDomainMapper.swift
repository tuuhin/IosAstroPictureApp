import Foundation

extension APODResponse {
    func toDomainModel() -> APODModel {
        return APODModel(date: date,
                         postId: Int(postId),
                         title: title,
                         mediaType: mediaType == .video ? .video : .image,
                         description: description,
                         credit: credit,
                         copyRight: copyRight,
                         alt: alt,
                         url: url.absoluteString,
                         hdURL: hdURL?.absoluteString)
    }
}
