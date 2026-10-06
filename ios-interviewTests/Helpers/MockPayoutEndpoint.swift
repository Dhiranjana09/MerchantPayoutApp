//
//  MockPayoutEndpoint.swift
//  ios-interview
//
//  Created by Dhiranjana Yadav on 06/10/2026.
//
import Foundation
@testable import ios_interview

struct MockPayoutPayload: Codable, Equatable, Sendable {
    let amount: Int
    let currency: String
}

struct MockPayoutIDResponse: Decodable {
    let id: String
}

struct MockPayoutEndpoint: APIEndpoint {
    let path = "/api/payouts"
    let method: HTTPMethod = .post
    let headers = ["Content-Type": "application/json"]
    let body: Data?

    init(payload: MockPayoutPayload? = nil, encoder: JSONEncoder = JSONEncoder()) throws {
        body = try payload.map(encoder.encode)
    }
}
