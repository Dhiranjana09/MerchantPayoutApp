import Foundation

enum API {
    nonisolated static let baseURL = URL(string: "http://api.checkout-interview.local")!

    // Pre-configured URLSession that routes through MockURLProtocol.
    // Use this (or URLSession.shared after registering MockURLProtocol) for all API calls.
    nonisolated static let session: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }()
}

nonisolated protocol APIClientProtocol {
    @concurrent
    func send<Response: Decodable & Sendable>(_ endpoint: any APIEndpoint, as type: Response.Type) async throws -> Response
}

nonisolated final class APIClient: APIClientProtocol, Sendable {
    private let session: URLSession
    private let baseURL: URL

    init(session: URLSession = API.session, baseURL: URL = API.baseURL) {
        self.session = session
        self.baseURL = baseURL
    }

    @concurrent
    func send<Response: Decodable & Sendable>(_ endpoint: any APIEndpoint, as type: Response.Type = Response.self) async throws -> Response {
        let request = endpoint.makeRequest(baseURL: baseURL)

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.server(
                    statusCode: httpResponse.statusCode,
                    message: errorMessage(from: data)
                )
            }

            do {
                return try JSONDecoder().decode(Response.self, from: data)
            } catch {
                throw NetworkError.decoding
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            throw error
        }
    }

    func errorMessage(from data: Data) -> String? {
        return try? JSONDecoder().decode(APIErrorResponse.self, from: data).error
    }
}
