//
//  MerchantHomeViewModel.swift
//  ios-interview
//
//  Created by Dhiranjana Yadav on 06/10/2026.
//
import Foundation
import Observation

@Observable
@MainActor
final class MerchantHomeViewModel {
    enum State {
        case loading
        case loaded(MerchantData)
        case failed(String)
    }

    private(set) var state: State = .loading

    private let repository: MerchantRepository

    init(repository: MerchantRepository = RemoteMerchantRepository()) {
        self.repository = repository
    }

    func load() async {
        state = .loading

        do {
            let merchant = try await repository.fetchMerchant()
            state = .loaded(merchant)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
