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
    
    @Relationship(deleteRule: .nullify, inverse: \TimeSession.activity)
    var sessions: [TimeSession]? = []
    
    init(name: String, color: Color = .blue) {
        self.name = name
        self.hexColor = color.toHex() ?? "0000FF"
    }
    
    @Transient
    var color: Color {
        return Color(hex: hexColor)
    }
    
    func updateDetails(newName: String, newColor: Color) {
        self.name = newName
        self.hexColor = newColor.toHex() ?? "0000FF"
        
        if let pastSessions = sessions {
            for session in pastSessions {
                session.savedActivityName = self.name
                session.savedActivityHex = self.hexColor
            }
        }
    }
}

@Model
class SessionGoal {
    var text: String
    var isCompleted: Bool
     
    init(text: String, isCompleted: Bool = false) {
        self.text = text
        self.isCompleted = isCompleted
    }
}

@Model
class TimeSession {
    var startTime: Date
    var endTime: Date?
    
    var savedActivityName: String
    var savedActivityHex: String
    
    var activity: Activity?
    
    @Relationship(deleteRule: .cascade)
    var goals: [SessionGoal] = []
    
    var distractRating: Int = 5
    var productivityRating: Int = 5
    var notes: String = ""
        
    init(startTime: Date = Date(), activity: Activity) {
        self.startTime = startTime
        self.activity = activity
        
        self.savedActivityName = activity.name
        self.savedActivityHex = activity.hexColor
        
        self.distractRating = 5
        self.productivityRating = 5
        self.notes = ""
    }
    
    var isRunning: Bool {
        endTime == nil
    }
    
    @Transient
    var displayTitle: String {
        return activity?.name ?? savedActivityName
    }
    
    @Transient
    var displayColor: Color {
        if let live = activity {
            return live.color
        }
        return Color(hex: savedActivityHex)
    }
}
