import Foundation
import SwiftData
import Domain

// MARK: - Generic SwiftData Persistence Client
public final class SwiftDataPersistenceClient<Model: SwiftDataModel, Builder: QueryBuilder>: PersistenceClient
where Builder.Entity == Model.DomainEntity, Builder.Query == FetchDescriptor<Model> {
    
    private let modelContainer: ModelContainer
    
    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }
    
    public func save(_ entity: Model.DomainEntity) async throws {
        let context = ModelContext(modelContainer)

        // Check if entity already exists (upsert)
        let descriptor = Builder.query(byId: entity.id)
        let existing = try context.fetch(descriptor).first

        if let existing {
            existing.update(from: entity)
        } else {
            let model = Model(from: entity)
            context.insert(model)
        }

        try context.save()
    }
    
    public func fetch(byId id: Model.DomainEntity.ID) async throws -> Model.DomainEntity? {
        let descriptor = Builder.query(byId: id)
        return try await fetch(where: descriptor).first
    }

    public func fetch(byFilter filter: Builder.Filter) async throws -> [Model.DomainEntity] {
        let descriptor = Builder.query(byFilter: filter)
        return try await fetch(where: descriptor)
    }

    public func fetchAll() async throws -> [Model.DomainEntity] {
        let context = ModelContext(modelContainer)
        return try context.fetch(FetchDescriptor<Model>()).map { $0.toDomain() }
    }
    
    public func delete(byId id: Model.DomainEntity.ID) async throws {
        let descriptor = Builder.query(byId: id)
        try await delete(where: descriptor)
    }

    public func delete(byFilter filter: Builder.Filter) async throws {
        let descriptor = Builder.query(byFilter: filter)
        try await delete(where: descriptor)
    }
    
    public func deleteAll() async throws {
        let context = ModelContext(modelContainer)
        try context.delete(model: Model.self)
        try context.save()
    }
    
    private func fetch(where descriptor: FetchDescriptor<Model>) async throws -> [Model.DomainEntity] {
        let context = ModelContext(modelContainer)
        return try context.fetch(descriptor).map { $0.toDomain() }
    }

    private func delete(where descriptor: FetchDescriptor<Model>) async throws {
        let context = ModelContext(modelContainer)
        try context.delete(model: Model.self, where: descriptor.predicate)
        try context.save()
    }
}
