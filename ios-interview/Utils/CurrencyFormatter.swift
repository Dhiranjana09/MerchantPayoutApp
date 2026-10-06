//
//  CurrencyFormatter.swift
//  ios-interview
//
//  Created by Dhiranjana Yadav on 06/10/2026.
//
import Foundation

enum CurrencyFormatter {
    static func string(pence: Int, currency: Currency, locale: Locale = .current) -> String {
        (Decimal(pence) / 100).formatted(
            .currency(code: currency.rawValue).locale(locale)
        )
    }
}
