//
//  MerchantPayoutRepository.swift
//  ios-interview
//
//  Created by Dhiranjana Yadav on 08/10/2026.
//
import Foundation

nonisolated enum PayoutInputValidator {
    static func amountInPence(from input: String, locale: Locale = .current) -> Int? {
        let normalized = input
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: locale.groupingSeparator ?? ",", with: "")
            .replacingOccurrences(of: locale.decimalSeparator ?? ".", with: ".")

        guard
            let amount = Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX")),
            amount > 0,
            amount <= Decimal(Int.max) / 100
        else {
            return nil
        }

        var value = amount * 100
        var rounded = Decimal()
        NSDecimalRound(&rounded, &value, 0, .plain)

        guard rounded == value else { return nil }
        return NSDecimalNumber(decimal: rounded).intValue
    }

    static func normalizedIBAN(_ input: String) -> String {
        input
            .uppercased()
            .components(separatedBy: .whitespacesAndNewlines)
            .joined()
    }

    static func isValidIBAN(_ input: String) -> Bool {
        let iban = normalizedIBAN(input)
        // TODO: Add comprehensive iban validity check.
        return (15...34).contains(iban.count)
    }
}
