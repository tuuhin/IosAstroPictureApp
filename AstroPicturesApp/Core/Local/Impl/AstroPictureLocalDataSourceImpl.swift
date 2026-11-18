import Foundation
import SwiftData

typealias APODEntity = LocalSchemaV1.APODEntity

@MainActor
final class AstroPictureLocalDataSourceImpl: AstroPictureLocalDataSource {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    /// list based observers
    private var observers: [UUID: AsyncStream<[AstroPictureModel]>.Continuation] = [:]
    /// entity based observers
    private var latestObservers: [UUID: AsyncStream<AstroPictureModel?>.Continuation] = [:]

    /// timezone corrected calendar
    private static let apodCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        let timeZone = TimeZone(secondsFromGMT: 0)
        if let zone = timeZone {
            calendar.timeZone = zone
        }
        return calendar
    }()

    func observeEntities() async throws -> AsyncStream<[AstroPictureModel]> {
        let id = UUID()

        return AsyncStream { continuation in
            self.observers[id] = continuation

            do {
                // Yield initial state
                try continuation.yield(self.fetchAllSync())
            } catch {
                // incase fetch all failed
                continuation.finish()
            }

            continuation.onTermination = { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.removeObserver(id)
                }
            }
        }
    }

    func observeLatest() async throws -> AsyncStream<AstroPictureModel?> {
        let id = UUID()
        return AsyncStream { continuation in
            self.latestObservers[id] = continuation
            do {
                try continuation.yield(self.fetchLatestSync())
            } catch LocalDbErrors.entryAbsent {
                continuation.yield(nil)
            } catch {
                continuation.finish()
            }
            continuation.onTermination = { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.latestObservers[id] = nil
                }
            }
        }
    }

    func fetchAll() async throws -> [AstroPictureModel] {
        try fetchAllSync()
    }

    func fetchLatest() async throws -> AstroPictureModel {
        try fetchLatestSync()
    }

    func fetchTodays() async throws -> AstroPictureModel {
        let today = Self.apodCalendar.startOfDay(for: .now)
        guard let tomorrow = Self.apodCalendar.date(byAdding: .day, value: 1, to: today) else {
            throw LocalDbErrors.entryAbsent
        }

        var descriptor = FetchDescriptor<APODEntity>(
            predicate: #Predicate<APODEntity> { entity in
                entity.date >= today && entity.date < tomorrow
            }
        )
        descriptor.fetchLimit = 1

        guard let result = try context.fetch(descriptor).first else {
            throw LocalDbErrors.entryAbsent
        }

        return result.toDomainModel()
    }

    func save(_ apod: AstroPictureModel) async throws {
        try saveInternal(apod)
        try context.save()
        try publishChanges()
    }

    func saveMultiple(_ apods: [AstroPictureModel]) async throws {
        for apod in apods {
            try saveInternal(apod)
        }
        try context.save()
        try publishChanges()
    }

    func delete(_ apod: AstroPictureModel) async throws {
        let postId = Int64(apod.postId)
        let descriptor = FetchDescriptor<APODEntity>(
            predicate: #Predicate<APODEntity> { $0.postId == postId }
        )

        if let entry = try context.fetch(descriptor).first {
            context.delete(entry)
            try context.save()
            try publishChanges()
        }
    }

    func deleteAll(_ apods: [AstroPictureModel]) async throws {
        let postIds = apods.map { Int64($0.postId) }
        let descriptor = FetchDescriptor<APODEntity>(
            predicate: #Predicate<APODEntity> { postIds.contains($0.postId) }
        )

        for entry in try context.fetch(descriptor) {
            context.delete(entry)
        }
        try context.save()
        try publishChanges()
    }

    private func saveInternal(_ apod: AstroPictureModel) throws {
        let postId = Int64(apod.postId)
        var descriptor = FetchDescriptor<APODEntity>(
            predicate: #Predicate<APODEntity> { $0.postId == postId }
        )
        descriptor.fetchLimit = 1

        if let existing = try context.fetch(descriptor).first {
            existing.date = apod.date
            existing.title = apod.title
            existing.mediaType = apod.mediaType.rawValue
            existing.apodDescription = apod.description
            existing.credit = apod.credit
            existing.copyRight = apod.copyRight
            existing.alt = apod.alt
            existing.url = apod.url
            existing.isFavourite = apod.isFav
            existing.hdURL = apod.hdURL
        } else {
            context.insert(apod.toEntity())
        }
    }

    private func fetchAllSync() throws -> [AstroPictureModel] {
        let descriptor = FetchDescriptor<APODEntity>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try context.fetch(descriptor).map { $0.toDomainModel() }
    }

    private func fetchLatestSync() throws -> AstroPictureModel {
        var descriptor = FetchDescriptor<APODEntity>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        guard let latestResult = try context.fetch(descriptor).first else {
            throw LocalDbErrors.entryAbsent
        }
        return latestResult.toDomainModel()
    }

    private func publishChanges() throws {
        let apods = try fetchAllSync()
        for continuation in observers.values {
            continuation.yield(apods)
        }
        let latest = apods.first
        for continuation in latestObservers.values {
            continuation.yield(latest)
        }
    }

    private func removeObserver(_ id: UUID) {
        observers[id] = nil
    }
}
