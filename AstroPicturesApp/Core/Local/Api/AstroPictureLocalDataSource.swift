protocol AstroPictureLocalDataSource {
    func fetchLatest() async throws -> AstroPictureModel
    func fetchTodays() async throws -> AstroPictureModel
    func fetchAll() async throws -> [AstroPictureModel]
    func fetchPage(page: Int, pageSize: Int) async throws -> [AstroPictureModel]

    func observeLatest() async throws -> AsyncStream<AstroPictureModel?>
    func observeEntities() async throws -> AsyncStream<[AstroPictureModel]>

    func saveMultiple(_ apods: [AstroPictureModel]) async throws
    func save(_ apod: AstroPictureModel) async throws

    func delete(_ apod: AstroPictureModel) async throws
    func deleteAll(_ apods: [AstroPictureModel]) async throws
}
