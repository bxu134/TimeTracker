//
//  Item.swift
//  TimeTracker
//
//  Created by Ben Xu on 2/18/26.
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
