import Foundation
import Domain

public protocol QueryBuilder {
    associatedtype Entity: Sendable & Identifiable
    associatedtype Filter
    associatedtype Query

    static func query(byId: Entity.ID) -> Query
    static func query(byFilter: Filter) -> Query
}

public protocol PersistenceClient<Entity, Builder>: Sendable {
    associatedtype Entity: Sendable & Identifiable
    associatedtype Builder: QueryBuilder where Builder.Entity == Entity
    associatedtype Filter where Filter == Builder.Filter
    associatedtype Query where Query == Builder.Query

    func save(_ entity: Entity) async throws
    func fetch(byId id: Entity.ID) async throws -> Entity?
    func fetch(byFilter filter: Filter) async throws -> [Entity]
    func fetchAll() async throws -> [Entity]
    func delete(byId id: Entity.ID) async throws
    func delete(byFilter filter: Filter) async throws
    func deleteAll() async throws
}
