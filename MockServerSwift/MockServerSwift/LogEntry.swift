//
//  LogEntry.swift
//  MockServerSwift
//
//  Created by Harish Kumar on 21/04/26.
//

import Foundation

struct LogEntry: Identifiable, Hashable {
    let id: UUID
    let timestamp: Date
    let method: String
    let path: String
    let statusCode: Int
    let requestBody: String
    let responseBody: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: LogEntry, rhs: LogEntry) -> Bool {
        return lhs.id == rhs.id
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: timestamp)
    }
}
