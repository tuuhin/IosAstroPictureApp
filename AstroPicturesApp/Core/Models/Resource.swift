enum Resource<T: Sendable, E: Sendable & Error> {
    case loading
    case success(data: T, message: String?)
    case error(error: E, message: String?, data: T?)
}
