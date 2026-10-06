//
//  MerchantRepository.swift
//  ios-interview
//
//  Created by Dhiranjana Yadav on 06/10/2026.
//
import Foundation

private struct MerchantEndpoint: APIEndpoint {
    var path: String { "/api/merchant" }
    var method: HTTPMethod { .get }
}

nonisolated protocol MerchantRepository {
    func fetchMerchant() async throws -> MerchantData
}

nonisolated final class RemoteMerchantRepository: MerchantRepository {
    private let client: APIClientProtocol

    init(client: APIClientProtocol = APIClient()) {
        self.client = client
    }

    func fetchMerchant() async throws -> MerchantData {
        try await client.send(MerchantEndpoint(), as: MerchantData.self)
    }
}
