//
//  APIClientTests.swift
//  ios-interview
//
//  Created by Dhiranjana Yadav on 06/10/2026.
//


import XCTest
import Foundation
@testable import ios_interview

@MainActor
final class APIClientTests: XCTestCase {
    override func tearDown() {
        StubURLProtocol.handler = nil
        super.tearDown()
    }
    
    private func makeClient() -> APIClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return APIClient(
            session: URLSession(configuration: configuration)
        )
    }

    func testEndpointEncodesItsJSONBodyAndSetsContentType() throws {
        let payload = MockPayoutPayload(amount: 9999, currency: "GBP")
        let endpoint = try MockPayoutEndpoint(payload: payload)

        let request = endpoint.makeRequest(baseURL: URL(string: "https://example.com")!)

        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
        XCTAssertEqual(request.url?.path, "/api/payouts")
        XCTAssertEqual(
            try JSONDecoder().decode(MockPayoutPayload.self, from: try XCTUnwrap(request.httpBody)),
            payload
        )
    }

    func testSendDecodesA2xxResponse() async throws {
        StubURLProtocol.handler = { request in
            .init(statusCode: 201, data: Data(#"{"id":"payout_1"}"#.utf8))
        }
        let client = makeClient()

        let response: MockPayoutIDResponse = try await client.send(MockPayoutEndpoint(), as: MockPayoutIDResponse.self)

        XCTAssertEqual(response.id, "payout_1")
    }

    func testSendMapsAnErrorResponseIncludingItsMessage() async {
        StubURLProtocol.handler = { _ in
            .init(statusCode: 503, data: Data(#"{"error":"Service temporarily unavailable"}"#.utf8))
        }
        let client = makeClient()

        do {
            let _: MockPayoutIDResponse = try await client.send(MockPayoutEndpoint(), as: MockPayoutIDResponse.self)
            XCTFail("Expected a server error")
        } catch let error as NetworkError {
            XCTAssertEqual(error, .server(statusCode: 503, message: "Service temporarily unavailable"))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
