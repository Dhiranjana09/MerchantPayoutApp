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
