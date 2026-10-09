//
//  MockMerchantRepository.swift
//  ios-interviewTests
//
//  Created by Dhiranjana Yadav on 09/10/2026.
//

import Foundation
@testable import ios_interview

final class MockMerchantRepository: MerchantRepository {
    private var response: Result<MerchantData, Error>
    
    init(response: Result<MerchantData, Error>) {
        self.response = response
    }
    
    func fetchMerchant() async throws -> MerchantData {
        return try response.get()
    }
}
