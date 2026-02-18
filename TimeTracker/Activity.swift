//
//  Activity.swift
//  TimeTracker
//
//  Created by Ben Xu on 2/18/26.
//

import Foundation
import SwiftData

@Model
class Activity {
    var name: String
    
    @Relationship(deleteRule: .cascade, inverse: \TimeSession.activity)
    var sessions: [TimeSession]? = []
    
    init(name: String) {
        self.name = name
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
