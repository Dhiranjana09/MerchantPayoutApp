//
//  ActivityRowView.swift
//  ios-interview
//
//  Created by Dhiranjana Yadav on 07/10/2026.
//
import SwiftUI

struct ActivityRowView: View {
    let activity: ActivityItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: activity.amount < 0 ? "arrow.up.right.circle.fill" : "arrow.down.left.circle.fill")
                .foregroundStyle(activity.amount < 0 ? .red : .green)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.description)
                    .lineLimit(1)
                
                ActivityStatusPill(status: activity.status)
            }
            
            Spacer()
            
            Text(CurrencyFormatter.string(
                pence: activity.amount,
                currency: activity.currency
            ))
            .fontWeight(.semibold)
            .foregroundStyle(activity.amount < 0 ? .red : .green)
            
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

private struct ActivityStatusPill: View {
    let status: ActivityStatus

    private var colors: (foreground: Color, background: Color) {
        switch status {
        case .completed:
            return (.green, .green.opacity(0.1))
        case .pending, .processing:
            return (.orange, .orange.opacity(0.1))
        case .failed:
            return (.red, .red.opacity(0.1))
        }
    }

    var body: some View {
        Text(status.rawValue.capitalized)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(colors.foreground)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(colors.background, in: Capsule())
            .accessibilityLabel("Status: \(status.rawValue)")
    }
}
