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
        static let sendPayoutTitle = "Send Payout"
        
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

    enum Payout {
        static let currencyTitle = "Currency"
        static let amountTitle = "Amount"
        static let ibanTitle = "IBAN"
        static let amountPlaceholder = "0.00"
        static let ibanPlaceholder = "GB29NWBK60161331926819"
        static let amountAccessibilityLabel = "Payout amount"
        static let ibanAccessibilityLabel = "Destination IBAN"
        static let amountValidationMessage = "Enter an amount greater than zero with no more than two decimal places."
        static let ibanHint = "International Bank Account Number, for example GB29NWBK60161331926819."
        static let ibanValidationMessage = "Enter a valid IBAN."
        static let sendNavigationTitle = "Send Payout"
        static let continueTitle = "Continue"
        static let confirmNavigationTitle = "Confirm Payout"
        static let confirmTitle = "Confirm Payout"
        static let backTitle = "Back"
        static let submittedTitle = "Payout Submitted"
        static let successNavigationTitle = "Success"
        static let doneTitle = "Done"
        static let payoutAuthenticationTitle = "Payout authentication"
        static let payoutAuthenticationCancelled = "Payout authentication was cancelled."
        static let okTitle = "OK"

        static func biometricUnavailableMessage(_ message: String) -> String {
            "Biometric authentication is unavailable. \(message)"
        }

        static func destinationLabel(_ iban: String) -> String {
            "to \(iban)"
        }

        static func referenceLabel(_ id: String) -> String {
            "Reference\n\(id)"
        }

        static func maskedIBAN(prefix: String, suffix: String) -> String {
            "\(prefix) **** **** \(suffix)"
        }
    }
}
