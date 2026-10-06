//
//  APIEndpoint.swift
//  ios-interview
//
//  Created by Dhiranjana Yadav on 06/10/2026.
//

import Foundation

nonisolated protocol APIEndpoint: Sendable {
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem] { get }
    var headers: [String: String] { get }
    var body: Data? { get }
}

extension APIEndpoint {
    nonisolated var queryItems: [URLQueryItem] { [] }
    nonisolated var headers: [String: String] { [:] }
    nonisolated var body: Data? { nil }

    nonisolated func makeRequest(baseURL: URL) -> URLRequest {
        var url = baseURL.appending(path: path)

        if !queryItems.isEmpty {
            url = url.appending(queryItems: queryItems)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue

        for (field, value) in headers {
            request.setValue(value, forHTTPHeaderField: field)
        }

        request.httpBody = body

        return request
    }
}
