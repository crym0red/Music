import Foundation

enum APIEnvironment {
    static let baseURL = URL(string: "https://api.example.com")!
}

enum APIError: LocalizedError {
    case invalidResponse
    case server(Int)
    case missingBaseURL

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "The server returned an invalid response."
        case .server(let status): return "The server returned HTTP \(status)."
        case .missingBaseURL: return "Configure APIEnvironment.baseURL before using the API."
        }
    }
}

struct APIClient {
    var baseURL: URL = APIEnvironment.baseURL
    var session: URLSession = .shared

    func request<T: Decodable>(
        path: String,
        method: String = "GET",
        body: Data? = nil,
        token: String? = nil
    ) async throws -> T {
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else {
            throw APIError.missingBaseURL
        }

        let cleanPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        components.path = (components.path.hasSuffix("/") ? components.path : components.path + "/") + cleanPath

        guard let url = components.url else {
            throw APIError.missingBaseURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        if let token, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200..<300).contains(http.statusCode) else {
            throw APIError.server(http.statusCode)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}

struct AuthResponse: Codable {
    let token: String
}

struct RemoteTrack: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let artist: String
    let artworkURL: URL?
    let streamURL: URL?
}

enum EightSpineEndpoints {
    static let login = "/auth/login"
    static let library = "/library"
    static let search = "/search"
    static let playlists = "/playlists"
}
