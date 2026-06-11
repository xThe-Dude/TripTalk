import Foundation

enum SupabaseError: Error, LocalizedError {
    case invalidURL
    case httpError(Int, String)
    case decodingError(Error)
    case noData
    case notAuthenticated

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .httpError(let code, let msg): return "HTTP \(code): \(msg)"
        case .decodingError(let err): return "Decode error: \(err.localizedDescription)"
        case .noData: return "No data returned"
        case .notAuthenticated: return "Not authenticated"
        }
    }
}

final class SupabaseClient: Sendable {
    static let shared = SupabaseClient()

    let baseURL = "https://fybfuykxbwhlhmjyscor.supabase.co"
    let apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ5YmZ1eWt4YndobGhtanlzY29yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzI5ODU3MDAsImV4cCI6MjA4ODU2MTcwMH0.K6jfzovubmVsIAGUQ3RZbta0RB1HGDPjjqm4NGL5Rh4"

    private let session: URLSession
    let decoder: JSONDecoder
    let encoder: JSONEncoder

    private init() {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 30
        config.httpCookieAcceptPolicy = .never
        config.httpShouldSetCookies = false
        session = URLSession(configuration: config)

        decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let str = try container.decode(String.self)
            if let d = ISO8601DateFormatter().date(from: str) { return d }
            let fmt = ISO8601DateFormatter()
            fmt.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let d = fmt.date(from: str) { return d }
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Bad date: \(str)"))
        }

        encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
    }

    // MARK: - Token

    var accessToken: String? {
        KeychainStore.read(key: "supabase_access_token")
    }

    private func authHeader() -> String {
        if let token = accessToken { return "Bearer \(token)" }
        return "Bearer \(apiKey)"
    }

    // MARK: - REST

    func get<T: Decodable>(_ table: String, query: [String: String] = [:]) async throws -> T {
        var components = URLComponents(string: "\(baseURL)/rest/v1/\(table)")!
        components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        guard let url = components.url else { throw SupabaseError.invalidURL }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue(authHeader(), forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        try checkResponse(response, data)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw SupabaseError.decodingError(error)
        }
    }

    func post<T: Encodable>(_ table: String, body: T, returnRepresentation: Bool = false) async throws -> Data {
        let url = URL(string: "\(baseURL)/rest/v1/\(table)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue(authHeader(), forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if returnRepresentation {
            request.setValue("return=representation", forHTTPHeaderField: "Prefer")
        }
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await session.data(for: request)
        try checkResponse(response, data)
        return data
    }

    func patch<T: Encodable>(_ table: String, query: [String: String], body: T) async throws {
        var components = URLComponents(string: "\(baseURL)/rest/v1/\(table)")!
        components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        guard let url = components.url else { throw SupabaseError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue(authHeader(), forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await session.data(for: request)
        try checkResponse(response, data)
    }

    func delete(_ table: String, query: [String: String]) async throws {
        var components = URLComponents(string: "\(baseURL)/rest/v1/\(table)")!
        components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        guard let url = components.url else { throw SupabaseError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue(authHeader(), forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        try checkResponse(response, data)
    }

    func rpc(_ functionName: String, params: [String: String] = [:]) async throws {
        let url = URL(string: "\(baseURL)/rest/v1/rpc/\(functionName)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue(authHeader(), forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: params)

        let (data, response) = try await session.data(for: request)
        try checkResponse(response, data)
    }

    // MARK: - Auth

    func authPost(_ endpoint: String, body: [String: Any], query: [String: String] = [:]) async throws -> Data {
        var components = URLComponents(string: "\(baseURL)/auth/v1/\(endpoint)")!
        if !query.isEmpty {
            components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        let url = components.url!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)
        try checkResponse(response, data)
        return data
    }

    func authGet(_ endpoint: String) async throws -> Data {
        let url = URL(string: "\(baseURL)/auth/v1/\(endpoint)")!
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        guard let token = accessToken else { throw SupabaseError.notAuthenticated }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await session.data(for: request)
        try checkResponse(response, data)
        return data
    }

    // MARK: - Storage

    func uploadFile(bucket: String, path: String, data fileData: Data, contentType: String = "image/jpeg") async throws -> String {
        let url = URL(string: "\(baseURL)/storage/v1/object/\(bucket)/\(path)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "apikey")
        request.setValue(authHeader(), forHTTPHeaderField: "Authorization")
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = fileData

        let (data, response) = try await session.data(for: request)
        try checkResponse(response, data)
        return "\(baseURL)/storage/v1/object/public/\(bucket)/\(path)"
    }

    // MARK: - Helpers

    private func checkResponse(_ response: URLResponse, _ data: Data) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard (200...299).contains(http.statusCode) else {
            let raw = String(data: data, encoding: .utf8) ?? "no body"
            // Sanitize: truncate and strip potential PII from error responses
            let sanitized = String(raw.prefix(200))
            throw SupabaseError.httpError(http.statusCode, sanitized)
        }
    }
}
