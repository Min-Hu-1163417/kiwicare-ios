//
//  Item.swift
//  KiwiCare
//
//  Created by Vincent Hu on 04/11/2026.
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
