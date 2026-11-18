import Foundation

extension APODResponse {
    func toDomainModel() -> AstroPictureModel {
        return AstroPictureModel(date: date,
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
