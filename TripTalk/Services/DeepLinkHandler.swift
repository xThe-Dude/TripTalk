import Foundation

/// Handles deep links: triptalk://strain/{id}, triptalk://service/{id}, triptalk://crisis
enum DeepLinkHandler {

    enum Destination: Equatable {
        case strain(UUID)
        case service(UUID)
        case substance(UUID)
        case crisis
        case home
        case authCallback(accessToken: String, refreshToken: String)
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
        case "auth":
            // Handle triptalk://auth/callback#access_token=...&refresh_token=...
            guard let fragment = url.fragment else { return nil }
            let params = Self.parseFragment(fragment)
            guard let accessToken = params["access_token"],
                  let refreshToken = params["refresh_token"] else { return nil }
            return .authCallback(accessToken: accessToken, refreshToken: refreshToken)
        default:
            return nil
        }
    }

    /// Parse URL fragment parameters (key=value&key2=value2)
    private static func parseFragment(_ fragment: String) -> [String: String] {
        var params: [String: String] = [:]
        for pair in fragment.split(separator: "&") {
            let parts = pair.split(separator: "=", maxSplits: 1)
            if parts.count == 2 {
                let key = String(parts[0])
                let value = String(parts[1]).removingPercentEncoding ?? String(parts[1])
                params[key] = value
            }
        }
        return params
    }
}
