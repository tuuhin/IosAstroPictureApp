import Foundation
import SwiftData

enum LocalSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [APODEntity.self]
    }

    @Model
    final class APODEntity {
        @Attribute(.unique)
        var postId: Int64
        var date: Date
        var title: String
        var mediaType: String
        var apodDescription: String
        var isFavourite: Bool
        var credit: String?
        var copyRight: String?
        var alt: String?
        var url: String
        var hdURL: String?

        init(
            postId: Int64,
            date: Date,
            title: String,
            mediaType: String,
            apodDescription: String,
            credit: String?,
            copyRight: String?,
            alt: String?,
            url: String,
            isFavourite: Bool,
            hdURL: String?
        ) {
            self.postId = postId
            self.date = date
            self.title = title
            self.mediaType = mediaType
            self.apodDescription = apodDescription
            self.credit = credit
            self.copyRight = copyRight
            self.alt = alt
            self.isFavourite = isFavourite
            self.url = url
            self.hdURL = hdURL
        }
    }
}
