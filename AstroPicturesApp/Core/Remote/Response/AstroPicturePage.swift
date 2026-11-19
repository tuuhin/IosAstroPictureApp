import Foundation

struct AstroPicturePage: Sendable {
    let pictures: [AstroPictureModel]
    let totalAvailablePictures: Int
    let totalPages: Int
}
