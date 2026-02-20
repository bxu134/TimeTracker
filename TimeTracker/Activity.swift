//
//  Activity.swift
//  TimeTracker
//
//  Created by Ben Xu on 2/18/26.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class Activity {
    var name: String
    var hexColor: String
    
    @Relationship(deleteRule: .cascade, inverse: \TimeSession.activity)
    var sessions: [TimeSession]? = []
    
    init(name: String, color: Color = .blue) {
        self.name = name
        self.hexColor = color.toHex() ?? "0000FF"
    }
    
    @Transient
    var color: Color {
        return Color(hex: hexColor)
    }
}

@Model
class TimeSession {
    var startTime: Date
    var endTime: Date?
    
    var activity: Activity?
    
    init(startTime: Date = Date(), activity: Activity) {
        self.startTime = startTime
        self.activity = activity
    }
    
    var isRunning: Bool {
        endTime == nil
    }
}
