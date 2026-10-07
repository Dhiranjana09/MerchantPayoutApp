//
//  AppStrings.swift
//  ios-interview
//
//  Created by Dhiranjana Yadav on 06/10/2026.
//
import Foundation

enum AppStrings {
    enum MerchantHome {
        static let accountLoadingTitle = "Loading your account…"
        static let accountLoadFailureText = "Unable to load account"
        static let tryAgainText = "Try again"
        static let navigationTitle = "Merchant dashboard"
        static let recentActivityText = "Recent activity"
        static let viewAllTitle = "View All"
        static let viewAllAccessibilityHint = "Opens your activity list"
        static let accountBalanceText = "Account balance"
        
        static func pendingBalanceLabel(_ amount: String) -> String {
            "Pending \(amount)"
        }
    }
    
    enum ActivityList {
        static let navigationTitle = String(localized: "Transactions")
        static let loadingTitle = "Loading transactions"
        static let emptyTitle = String(localized: "No transactions")
        static let loadingMoreTitle = String(localized: "Loading more…")
        static let retryLoadingMoreTitle = String(localized: "Retry loading more")
        static let failureTitle = String(localized: "Unable to load transactions")
    }
}
