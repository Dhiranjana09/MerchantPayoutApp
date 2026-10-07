//
//  MerchantActivityRepository.swift
//  ios-interview
//
//  Created by Dhiranjana Yadav on 07/10/2026.
//

import Foundation

private struct MerchantActivityEndpoint: APIEndpoint {
    var path: String { "/api/merchant/activity" }
    var method: HTTPMethod { .get }
    let cursor: String?
    var queryItems: [URLQueryItem] {
        if let cursor = cursor {
            return [URLQueryItem(name: "cursor", value: cursor)]
        }
        return []
    }
}

nonisolated protocol MerchantActivityRepository {
    func fetchActivity(cursor: String?) async throws -> PaginatedActivityResponse
}

nonisolated final class RemoteMerchantActivityRepository: MerchantActivityRepository {
    private let client: APIClientProtocol

    init(client: APIClientProtocol = APIClient()) {
        self.client = client
    }

    func fetchActivity(cursor: String?) async throws -> PaginatedActivityResponse {
        try await client.send(
            MerchantActivityEndpoint(cursor: cursor),
            as: PaginatedActivityResponse.self
        )
    }
}
