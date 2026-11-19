import Foundation

struct PagedAstroPicturesModel: Sendable {
    let models: [AstroPictureModel]
    let hasMore: Bool
    let isFromCache: Bool
}
