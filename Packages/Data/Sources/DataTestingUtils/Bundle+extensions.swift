import Foundation

public extension Bundle {
    static func data(from file: String) -> Data {
        Bundle.module.data(from: file)
    }

    func decode<T: Decodable>(_ type: T.Type, from file: String) -> T {
        let data = data(from: file)
        let decoder = JSONDecoder()

        guard let loaded = try? decoder.decode(T.self, from: data) else {
            fatalError("Error: Failed to decode \(file) from bundle.")
        }
        return loaded
    }

    func data(from file: String) -> Data {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Error: Failed to locate \(file) in bundle.")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Error: Failed to load \(file) from bundle.")
        }
        return data
    }
}
