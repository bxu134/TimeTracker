//
//  DashboardView.swift
//  TimeTracker
//
//  Created by Ben Xu on 2/21/26.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TimeSession.startTime, order: .reverse) private var sessions: [TimeSession]
    @Query(sort: \Activity.name) private var activities: [Activity]
    
    @State private var currTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
     
    @State private var isBreathing = false
    
    var activeSession: TimeSession? {
        sessions.first(where: { $0.isRunning })
    }
    
    var body: some View {
        NavigationStack {
            ScrollView{
                VStack(spacing: 20) {
                    if let active = activeSession {
                        activeSessionCard(active)
                    }
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .onReceive(timer) { input in
                currTime = input
            }
        }
    }
    
    @ViewBuilder
    private func activeSessionCard(_ session: TimeSession) -> some View {
        let elapsed = currTime.timeIntervalSince(session.startTime)
        
        VStack() {
            HStack {
                Circle()
                    .fill(session.displayColor)
                    .frame(width: 10, height: 10)
                
                Text(session.displayTitle)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("In Progress")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(session.displayColor)
                    .padding(.horizontal, 7.5)
                    .padding(.vertical, 3)
                    .background(session.displayColor.opacity(0.15))
                    .cornerRadius(6)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            Text(formatElapsed(elapsed))
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .monospacedDigit()
                .padding(.bottom, 4)
            
            if !session.goals.isEmpty {
                Divider()
                    .frame(height: 2)
                    .overlay(Color.gray.opacity(0.2))
                    .padding(.horizontal, 16)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Session Goals")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                        .padding(.top, 12)
                    
                    ForEach(session.goals) { goal in
                        HStack(spacing: 10) {
                            Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(goal.isCompleted ? .green : .secondary)
                                .font(.body)
                            
                            Text(goal.text)
                                .font(.subheadline)
                                .strikethrough(goal.isCompleted)
                                .foregroundColor(goal.isCompleted ? .secondary : .primary)
                            
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                goal.isCompleted.toggle()
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(session.displayColor.opacity(isBreathing ? 0.5 : 0.15), lineWidth: (isBreathing ? 3 : 1.5))
                .shadow(color: session.displayColor.opacity(isBreathing ? 0.4 : 0.1), radius: isBreathing ? 8 : 0)
                .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: isBreathing)
        )
        .onAppear {
            DispatchQueue.main.async {
                isBreathing = true
            }
        }
    }
    
    private func formatElapsed(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
