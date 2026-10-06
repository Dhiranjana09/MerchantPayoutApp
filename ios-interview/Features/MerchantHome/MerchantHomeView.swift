//
//  MerchantHomeView.swift
//  ios-interview
//
//  Created by Dhiranjana Yadav on 06/10/2026.
//
import SwiftUI

struct MerchantHomeView: View {
    @State private var viewModel = MerchantHomeViewModel()
    @State private var isActivitySheetPresented = false

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .loading:
                    ProgressView(AppStrings.MerchantHome.accountLoadingTitle)
                case let .loaded(merchant):
                    MerchantOverview(merchant: merchant) {
                        isActivitySheetPresented = true
                    }
                case let .failed(message):
                    ContentUnavailableView {
                        Label(AppStrings.MerchantHome.accountLoadFailureText, systemImage: "exclamationmark.triangle")
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
            .navigationTitle(AppStrings.MerchantHome.navigationTitle)
            .task { await viewModel.load() }
            .sheet(isPresented: $isActivitySheetPresented) {
                if case let .loaded(merchant) = viewModel.state {
                    ActivitySheet(activities: merchant.activity)
                }
            }
        }
    }
}

private struct MerchantOverview: View {
    let merchant: MerchantData
    let showMore: () -> Void

    var body: some View {
        List {
            Section {
                BalanceSummaryView(merchant: merchant)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }

            Section {
                ForEach(merchant.activity.prefix(3)) { activity in
                    ActivityPreviewRow(activity: activity)
                }
            } header: {
                HStack {
                    Text(AppStrings.MerchantHome.recentActivityText)
                        .font(.headline.bold())

                    Spacer()

                    Button(AppStrings.MerchantHome.viewAllTitle, action: showMore)
                        .accessibilityHint(AppStrings.MerchantHome.viewAllAccessibilityHint)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

private struct BalanceSummaryView: View {
    let merchant: MerchantData

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(AppStrings.MerchantHome.accountBalanceText)
                .font(.headline)

            Text(CurrencyFormatter.string(pence: merchant.available_balance, currency: merchant.currency))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .accessibilityLabel("Available balance \(CurrencyFormatter.string(pence: merchant.available_balance, currency: merchant.currency))")

            Label {
                Text(
                    AppStrings.MerchantHome.pendingBalanceLabel(
                        CurrencyFormatter.string(pence: merchant.pending_balance, currency: merchant.currency)
                    )
                )
            } icon: {
                Image(systemName: "clock")
            }
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.background)
    }
}

private struct ActivityPreviewRow: View {
    let activity: ActivityItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: activity.amount < 0 ? "arrow.up.right.circle.fill" : "arrow.down.left.circle.fill")
                .foregroundStyle(activity.amount < 0 ? .red : .green)
                .font(.title3)

            Text(activity.description)
                .lineLimit(1)

            Spacer()

            Text(CurrencyFormatter.string(pence: abs(activity.amount), currency: activity.currency))
                .fontWeight(.semibold)
                .foregroundStyle(activity.amount < 0 ? .red : .green)
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }
}

private struct ActivitySheet: View {
    @Environment(\.dismiss) private var dismiss
    let activities: [ActivityItem]

    var body: some View {
        NavigationStack {
            List(activities) { activity in
                ActivityPreviewRow(activity: activity)
            }
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done", action: dismiss.callAsFunction)
                }
            }
        }
    }
}
