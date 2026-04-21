//
//  Item.swift
//  MockServerSwift
//
//  Created by Harish Kumar on 21/04/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
