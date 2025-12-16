import Foundation
import Domain
import SwiftData

public protocol SwiftDataModel: DomainRepresentable, PersistentModel {
    init(from entity: DomainEntity)
    func update(from entity: DomainEntity)
}
