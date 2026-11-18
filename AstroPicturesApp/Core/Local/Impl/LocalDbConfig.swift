import SwiftData

enum LocalDbConfig {
    /// migration plan
    private enum LocalMigrationPlan: SchemaMigrationPlan {
        static var schemas: [any VersionedSchema.Type] {
            [
                // current v1 schema
                LocalSchemaV1.self,
            ]
        }

        static var stages: [MigrationStage] {
            // empty as we dont have any migrations
            // add light weight migrations if needed
            []
        }
    }

    static let dbModelContainer: ModelContainer = {
        do {
            return try ModelContainer(for: Schema(versionedSchema: LocalSchemaV1.self), migrationPlan: LocalMigrationPlan.self)
        } catch {
            fatalError("Failed to create persistent container: \(error)")
        }
    }()

    static let memoryModelContainer: ModelContainer = {
        do {
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true)

            return try ModelContainer(for: Schema(versionedSchema: LocalSchemaV1.self),
                                      migrationPlan: LocalMigrationPlan.self,
                                      configurations: configuration)
        } catch {
            fatalError("Failed to create in-memory container: \(error)")
        }
    }()
}
