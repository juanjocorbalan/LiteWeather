import Foundation
import Domain
import SwiftData

public enum WeatherFilter {
    case byId(String)
    case latest
}

public enum WeatherQueryBuilder: QueryBuilder {
    public typealias Entity = Weather
    
    public static func query(byId: Entity.ID) -> FetchDescriptor<WeatherCacheModel> {
        query(byFilter: .byId(byId))
    }
    
    public static func query(byFilter filter: WeatherFilter) -> FetchDescriptor<WeatherCacheModel> {
        var descriptor = FetchDescriptor<WeatherCacheModel>()
        switch filter {

        case .byId(let id):
            descriptor.predicate = #Predicate { $0.id == id }

        case .latest:
            descriptor.predicate = #Predicate { _ in true }
            descriptor.sortBy = [SortDescriptor(\.weatherTimestamp, order: .reverse)]
            descriptor.fetchLimit = 1
        }

        return descriptor
    }
}
