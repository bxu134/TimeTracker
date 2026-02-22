//
//  SessionDetailView.swift
//  TimeTracker
//
//  Created by Ben Xu on 2/21/26.
//

import SwiftUI
import SwiftData

struct SessionDetailView: View {
    var session: TimeSession
    var onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Session Details")
                    .font(.headline)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            
            Divider()
            
            ScrollView {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Activity")
                            Spacer()
                            Text(session.displayTitle)
                                .foregroundColor(.secondary)
                        }
                        
                        if let endTime = session.endTime {
                            let duration = endTime.timeIntervalSince(session.startTime)
                            HStack {
                                Text("Duration")
                                Spacer()
                                Text(formatDuration(duration))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Productivity")
                            Spacer()
                            Text("\(session.productivityRating) / 10")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        RatingBarView(rating: session.productivityRating)
                        
                        Divider().padding(.vertical, 4)
                        
                        HStack {
                            Text("Distractedness")
                            Spacer()
                            Text("\(session.distractRating) / 10")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        RatingBarView(rating: session.distractRating)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    
                    if !session.goals.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tasks & Goals")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            ForEach(session.goals) { goal in
                                HStack {
                                    Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(goal.isCompleted ? .green : .secondary)
                                    Text(goal.text)
                                        .strikethrough(goal.isCompleted)
                                        .foregroundColor(goal.isCompleted ? .secondary : .primary)
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
        .frame(maxWidth: 340, maxHeight: 550)
        .background(Color(UIColor.systemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
    }

    private func formatDuration(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}


struct RatingBarView: View {
    var rating: Int
    let maxRating = 10
    
    var barColor: Color {
        if rating < 4 {
            return .red
        } else if rating < 7 {
            return .yellow
        } else {
            return .green
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maxRating, id: \.self) { index in
                Capsule()
                    .fill(index <= rating ? barColor : Color.gray.opacity(0.2))
                    .frame(height: 8)
            }
        }
    }
}
