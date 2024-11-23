import Foundation

extension Set: @retroactive RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        do {
            self = try JSONDecoder()
                .decode(Set<Element>.self, from: Data(rawValue.utf8))
        } catch {
            return nil
        }
    }

    public var rawValue: String {
        (try? JSONEncoder().encode(self))
            .flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
    }
}
