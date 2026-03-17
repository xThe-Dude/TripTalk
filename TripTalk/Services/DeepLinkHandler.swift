import Foundation

/// Handles deep links: triptalk://strain/{id}, triptalk://service/{id}, triptalk://crisis
enum DeepLinkHandler {

    enum Destination: Equatable {
        case strain(UUID)
        case service(UUID)
        case substance(UUID)
        case crisis
        case home
    }

    /// Parse a URL into a navigation destination.
    /// Supports:
    ///   triptalk://strain/{uuid}
    ///   triptalk://service/{uuid}
    ///   triptalk://substance/{uuid}
    ///   triptalk://crisis
    ///   triptalk://home
    static func parse(_ url: URL) -> Destination? {
        guard url.scheme == "triptalk" else { return nil }

        let host = url.host ?? ""
        let pathId = url.pathComponents.dropFirst().first.flatMap { UUID(uuidString: $0) }

        switch host {
        case "strain":
            guard let id = pathId else { return nil }
            return .strain(id)
        case "service":
            guard let id = pathId else { return nil }
            return .service(id)
        case "substance":
            guard let id = pathId else { return nil }
            return .substance(id)
        case "crisis":
            return .crisis
        case "home":
            return .home
        default:
            return nil
        }
    }
}
