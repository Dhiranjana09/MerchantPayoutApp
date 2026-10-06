//
//  NetworkError.swift
//  ios-interview
//
//  Created by Dhiranjana Yadav on 06/10/2026.
//
import Foundation

enum NetworkError: LocalizedError, Equatable {
    case invalidResponse
    case server(statusCode: Int, message: String?)
    case decoding

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned an invalid response."
        case let .server(statusCode, message):
            return message ?? "The request failed with status code \(statusCode)."
        case .decoding:
            return "We couldn't read the server response."
        }
    }
}
