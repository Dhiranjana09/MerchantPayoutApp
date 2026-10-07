//
//  ActivityListViewModel.swift
//  ios-interview
//
//  Created by Dhiranjana Yadav on 07/10/2026.
//
import Foundation
import Observation

@Observable
@MainActor
final class ActivityListViewModel {
    enum PaginationState {
        case ready(cursor: String)
        case loading(cursor: String)
        case failed(cursor: String, message: String)
        case finished
        
        var cursor: String? {
            switch self {
            case let .ready(cursor), let .loading(cursor), let .failed(cursor, _):
                return cursor
            case .finished:
                return nil
            }
        }
    }
    
    enum State {
        case loading
        case loaded(items: [ActivityItem], pagination: PaginationState)
        case failed(String)
    }

    private(set) var state: State = .loading

    private let repository: MerchantActivityRepository

    init(repository: MerchantActivityRepository = RemoteMerchantActivityRepository()) {
        self.repository = repository
    }

    func load() async {
        state = .loading

        do {
            let page = try await repository.fetchActivity(cursor: nil)
            try Task.checkCancellation()

            let paginationState = try createPaginationState(for: page, requestedCursor: nil)
            state = .loaded(
                items: page.items,
                pagination: paginationState
            )
        } catch is CancellationError {
          // Navigating Away cancels screen tasks
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
    
    func loadMore() async {
        guard case let .loaded(items, pagination) = state else {return }
        
        var cursor: String
        switch pagination {
        case let .ready(nextCursor), let .failed(nextCursor, _):
            cursor = nextCursor
        case .loading, .finished:
            return
        }
        
        state = .loaded(items: items, pagination: .loading(cursor: cursor))

        do {
            let page = try await repository.fetchActivity(cursor: cursor)
            try Task.checkCancellation()

            let existingIDs = Set(items.map(\.id))
            let newItems = page.items.filter { !existingIDs.contains($0.id)}
            let paginationState = try createPaginationState(for: page, requestedCursor: cursor)
            state = .loaded(
                items: items + newItems,
                pagination: paginationState
            )
        } catch is CancellationError {
            state = .loaded(items: items, pagination: .ready(cursor: cursor))
        } catch {
            guard !Task.isCancelled else {
                state = .loaded(items: items, pagination: .ready(cursor: cursor))
                return
            }
            state = .loaded(items: items, pagination: .failed(cursor: cursor, message: error.localizedDescription))
        }
    }
    
    private func createPaginationState(
        for page: PaginatedActivityResponse,
        requestedCursor: String?
    ) throws -> PaginationState {
        guard page.has_more else {
            return .finished
        }
        
        guard let nextCursor = page.next_cursor, nextCursor != requestedCursor else {
            throw NetworkError.invalidResponse
        }
        
        return .ready(cursor: nextCursor)
    }
}
