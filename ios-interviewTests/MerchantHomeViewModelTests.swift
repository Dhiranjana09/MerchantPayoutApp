//
//  MerchantHomeViewModelTests.swift
//  ios-interviewTests
//
//  Created by Dhiranjana Yadav on 09/10/2026.
//

import XCTest
@testable import ios_interview

@MainActor
final class MerchantHomeViewModelTests: XCTestCase {
    func testLoadingAndSuccess() async {
        let merchantData = MerchantData(available_balance: 50000,
                                        pending_balance: 250,
                                        currency: .GBP,
                                        activity: [ActivityItem(id: "act_01", type: .deposit, amount: 500, currency: .GBP, date: "2026-09-09T10:00:00.000Z", description: "Payment", status: .completed)])
        let repository = MockMerchantRepository(response: .success(merchantData))
        
        let viewModel = MerchantHomeViewModel(repository: repository)
        
        await viewModel.load()
        
        guard case let .loaded(merchant) = viewModel.state else {
            return XCTFail("Expected loaded state with merchant")
        }
        
        XCTAssertEqual(merchant.available_balance, 50000)
        XCTAssertEqual(merchant.pending_balance, 250)
        XCTAssertEqual(merchant.activity.map(\.id), ["act_01"])
    }
    
    func testFailure() async {
        let repository = MockMerchantRepository(response: .failure(NetworkError.server(statusCode: 503, message: "Please Try again")))
        
        let viewModel = MerchantHomeViewModel(repository: repository)
        
        await viewModel.load()
        
        guard case let .failed(message) = viewModel.state else {
            return XCTFail("Expected failure")
        }
        
        XCTAssertEqual(message, "Please Try again")
    }
}
