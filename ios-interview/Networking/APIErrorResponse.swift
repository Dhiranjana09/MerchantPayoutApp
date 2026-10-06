//
//  APIErrorResponse.swift
//  ios-interview
//
//  Created by Dhiranjana Yadav on 06/10/2026.
//
import Foundation

nonisolated struct APIErrorResponse: Decodable & Sendable {
    let error: String?
}
