//
//  ActivityListView.swift
//  ios-interview
//
//  Created by Dhiranjana Yadav on 07/10/2026.
//
import SwiftUI

struct ActivityListView: View {
    @State private var viewModel = ActivityListViewModel()
    
    var body: some View {
        content
            .navigationTitle(AppStrings.ActivityList.navigationTitle)
            .task {
                await viewModel.load()
            }
    }
    
    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView(AppStrings.ActivityList.loadingTitle)
        case let .loaded(activities, .finished) where activities.isEmpty:
            ContentUnavailableView(
                AppStrings.ActivityList.emptyTitle,
                systemImage: "tray"
            )
        case let .loaded(activities, pagination):
            List {
                ForEach(activities) { activity in
                    ActivityRowView(activity: activity)
                }
                
                if pagination.cursor != nil {
                    paginationFooter(for: pagination)
                }
            }
        case let .failed(message):
            ContentUnavailableView {
                Label(
                    AppStrings.ActivityList.failureTitle,
                    systemImage: "exclamationmark.triangle"
                )
            } description: {
                Text(message)
            } actions: {
                Button(AppStrings.MerchantHome.tryAgainText) {
                    Task { await viewModel.load() }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    @ViewBuilder
    private func paginationFooter(
        for pagination: ActivityListViewModel.PaginationState
    ) -> some View {
        VStack(spacing: 8) {
            switch pagination {
            case .ready:
                Color.clear.frame(height: 1)
            case .loading:
                HStack {
                    Spacer()
                    ProgressView(AppStrings.ActivityList.loadingMoreTitle)
                    Spacer()
                }
            case let .failed(_, message):
                VStack(spacing: 8) {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    
                    Button(AppStrings.ActivityList.retryLoadingMoreTitle) {
                        Task { await viewModel.loadMore() }
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowSeparator(.hidden)
            case .finished:
                EmptyView()
            }
        }
        .frame(maxWidth: .infinity)
        .listRowSeparator(.hidden)
        .task(id: pagination.cursor) {
            guard case .ready = pagination else {
                return
            }
            
            await viewModel.loadMore()
        }
    }
}
