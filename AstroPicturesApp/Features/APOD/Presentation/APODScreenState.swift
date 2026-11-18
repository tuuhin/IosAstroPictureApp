import Foundation

enum APODScreenState {
    case idle
    case loading
    case success(AstroPictureModel)
    case failure(Error)
}
