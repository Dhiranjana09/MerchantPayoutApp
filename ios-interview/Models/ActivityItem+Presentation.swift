//
//  ActivityItem+Presentation.swift
//  ios-interview
//
//  Created by Dhiranjana Yadav on 08/10/2026.
//

import Foundation

extension ActivityItem {
    var dateValue: Date {
    ISO8601DateFormatter.withFractionalSeconds.date(from: date) ?? ISO8601DateFormatter().date(from: date) ?? .distantPast
  }
}

extension ISO8601DateFormatter {
    static let withFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
}

struct ActivityDateGroup: Identifiable {
    let date: Date
    let activites: [ActivityItem]
    
    var id: Date {
        Calendar.current.startOfDay(for: date)
    }
    
    var title: String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        }
        
        if calendar.isDateInYesterday(date){
            return "Yesterday"
        }
        
        return date.formatted(.dateTime.day().month(.wide).year())
    }
}

extension DateFormatter {
    static let activityRowDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.calendar = .current
        formatter.timeZone = .current
        formatter.dateFormat = "dd MM yyyy"
        return formatter
    }()
}
