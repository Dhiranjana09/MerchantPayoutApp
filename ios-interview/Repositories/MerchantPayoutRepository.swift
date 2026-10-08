//
//  MerchantPayoutRepository.swift
//  ios-interview
//
//  Created by Dhiranjana Yadav on 08/10/2026.
//

import Foundation

private struct MerchantPayoutEndpoint: APIEndpoint {
    var path: String { "/api/payouts" }
    var method: HTTPMethod { .post }
    let headers = ["Content-Type": "application/json"]
    let body: Data?

    init(amount: Int, currency: Currency, iban: String, deviceId: String? = nil) throws {
        body = try JSONEncoder().encode(
            PayoutRequestBody(
                amount: amount,
                currency: currency,
                iban: iban,
                deviceId: deviceId
            )
        )
    }
}

nonisolated protocol MerchantPayoutRepository {
    func sendPayout(
        amount: Int,
        currency: Currency,
        iban: String,
        deviceId: String?
    ) async throws -> PayoutResponse
}

nonisolated final class RemoteMerchantPayoutRepository: MerchantPayoutRepository {
    private let client: APIClientProtocol

    init(client: APIClientProtocol = APIClient()) {
        self.client = client
    }

    func sendPayout(
        amount: Int,
        currency: Currency,
        iban: String,
        deviceId: String? = nil
    ) async throws -> PayoutResponse {
        let endpoint = try MerchantPayoutEndpoint(
            amount: amount,
            currency: currency,
            iban: iban,
            deviceId: deviceId
        )
        return try await client.send(endpoint, as: PayoutResponse.self)
    }
}

private nonisolated struct PayoutRequestBody: Encodable, Sendable {
    let amount: Int
    let currency: Currency
    let iban: String
    let deviceId: String?

    enum CodingKeys: String, CodingKey {
        case amount, currency, iban
        case deviceId = "device_id"
    }
}
