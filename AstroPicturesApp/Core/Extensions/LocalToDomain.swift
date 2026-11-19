import Foundation

extension APODEntity {
    func toDomainModel() -> AstroPictureModel {
        AstroPictureModel(
            date: date,
            postId: Int(postId),
            title: title,
            mediaType: mediaType == "video" ? .video : .image,
            description: apodDescription,
            credit: credit,
            copyRight: copyRight,
            alt: alt,
            url: url,
            hdURL: hdURL,
            isFav: isFavourite
        )
    }
}

extension AstroPictureModel {
    func toEntity() -> APODEntity {
        APODEntity(
            postId: Int64(postId),
            date: date,
            title: title,
            mediaType: mediaType.rawValue,
            apodDescription: description,
            credit: credit,
            copyRight: copyRight,
            alt: alt,
            url: url,
            isFavourite: isFav,
            hdURL: hdURL
        )
    }
}
