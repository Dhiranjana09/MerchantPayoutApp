import Foundation

nonisolated enum Currency: String, Codable, Sendable { case GBP, EUR }
nonisolated enum ActivityType: String, Codable, Sendable { case payout, deposit, refund, fee }
nonisolated enum ActivityStatus: String, Codable, Sendable { case completed, pending, processing, failed }
nonisolated enum PayoutStatus: String, Codable, Sendable { case pending, processing, completed, failed }

nonisolated struct ActivityItem: Codable, Identifiable, Sendable {
    let id: String
    let type: ActivityType
    let amount: Int          // in pence, negative for outflows
    let currency: Currency
    let date: String         // ISO 8601
    let description: String
    let status: ActivityStatus
}

nonisolated struct MerchantData: Codable, Sendable {
    let available_balance: Int
    let pending_balance: Int
    let currency: Currency
    let activity: [ActivityItem]
}

nonisolated struct PaginatedActivityResponse: Codable, Sendable {
    let items: [ActivityItem]
    let next_cursor: String?
    let has_more: Bool
}

nonisolated struct PayoutResponse: Codable, Sendable {
    let id: String
    let status: PayoutStatus
    let amount: Int
    let currency: Currency
    let iban: String
    let created_at: String
}
