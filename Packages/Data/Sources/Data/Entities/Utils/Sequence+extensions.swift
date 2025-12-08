import Foundation

extension Sequence where Iterator.Element: DomainRepresentable {
    func toDomain() -> [Iterator.Element.DomainEntity] {
        map { $0.toDomain() }
    }
}
