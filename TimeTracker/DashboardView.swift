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
    
    @State private var selectedSession: TimeSession?
    @State private var showActivityList = false
    
    var activeSession: TimeSession? {
        sessions.first(where: { $0.isRunning })
    }
    
    private var recentSessions: [TimeSession] {
        sessions.filter { !$0.isRunning }.prefix(8).map {$0}
    }
    
    var body: some View {
        ZStack {
            NavigationStack {
                ScrollView{
                    VStack(spacing: 20) {
                        HStack {
                            Text("Dashboard")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Menu {
                                Button {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        showActivityList = true
                                    }
                                } label : {
                                    Label("View Activity List", systemImage: "list.bullet")
                                }
                            } label : {
                                Image(systemName: "line.3.horizontal")
                                    .font(.title2)
                                    .foregroundColor(.primary)
                                    .padding(8)
                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.bottom, 8)
                        
                        if let active = activeSession {
                            activeSessionCard(active)
                        }
                        
                        streakSection
                        
                        recentSessionsSection
                        
                    }
                    .padding()
                }
                .onReceive(timer) { input in
                    currTime = input
                }
            }
            
            if showActivityList {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showActivityList = false
                        }
                    }
                    .zIndex(3)
                
                ActivityListView(onClose: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showActivityList = false
                    }
                })
                .zIndex(4)
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }
            
            if let session = selectedSession {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedSession = nil
                        }
                    }
                    .zIndex(1)
                
                SessionDetailView(session: session, onClose: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedSession = nil
                    }
                })
                .zIndex(2)
                .transition(.scale(scale: 0.9).combined(with: .opacity))
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
            .padding(.top, 8)
            
            Text(formatElapsed(elapsed))
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .monospacedDigit()
                .padding(.bottom, (session.goals.isEmpty ? 16 : 4))
            
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
    
    private var streakSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Activity")
                .font(.headline)
            
            HStack(spacing: 16) {
                streakStat(
                    value: "\(currentStreak)",
                    label: "Day Streak",
                    icon: "flame.fill",
                    color: .orange
                )
                
                streakStat(
                    value: "\(daysTrackedThisWeek)/7",
                    label: "This Week",
                    icon: "calendar",
                    color: .blue
                )
                
                streakStat(
                    value: "\(totalSessionsThisWeek)",
                    label: "Sessions",
                    icon: "bolt.fill",
                    color: .purple
                )
            }
            
            weekGrid
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }
    
    private func streakStat(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.caption)
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
            }
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var weekGrid: some View {
        var cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        cal.firstWeekday = 2
        
        let currWeekStart = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        let targetWeek = cal.date(byAdding: .weekOfYear, value: 0, to: currWeekStart)!
        
        let days: [Date] = (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: targetWeek) }
        
        return HStack(spacing: 6) {
            ForEach(days, id: \.self) { day in
                let hasSession = dayHasSession(day)
                let isToday = cal.isDateInToday(day)
                
                VStack(spacing: 4) {
                    Text(day.formatted(.dateTime.weekday(.narrow)))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(hasSession ? Color.green.opacity(0.8) : Color(UIColor.tertiarySystemFill))
                        .frame(height:24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(isToday ? Color.primary.opacity(0.3) : Color.clear, lineWidth: 1)
                        )
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var recentSessionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Sessions")
                .font(.headline)
            
            if recentSessions.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "clock")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        
                        Text("No sessions yet")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 24)
                    Spacer()
                }
            } else {
                let grouped = groupedByDay(recentSessions)
                
                ForEach(grouped, id: \.0) { dayString, daySessions in
                    Text(dayString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    
                    ForEach(daySessions) { session in
                        recentSessionRow(session)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }
    
    private func recentSessionRow(_ session: TimeSession) -> some View {
        let duration = (session.endTime ?? currTime).timeIntervalSince(session.startTime)
        let completedGoals = session.goals.filter { $0.isCompleted }.count
        let totalGoals = session.goals.count
        
        return HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(session.displayColor)
                .frame(width: 4, height: 40)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(session.displayTitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(session.startTime.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 3) {
                Text(formatDuration(duration))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .monospacedDigit()
                
                if totalGoals > 0 {
                    HStack(spacing: 3) {
                        Image(systemName: "target")
                            .font(.caption2)
                        Text("\(completedGoals)/\(totalGoals)")
                            .font(.caption)
                    }
                    .foregroundColor(completedGoals == totalGoals ? .green : .secondary)
                }
            }
        }
        .padding(8)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(session.displayColor.opacity(0.3), lineWidth: (1.5))
                .shadow(color: session.displayColor.opacity(0.2), radius: 8 )
        )
        .padding(.vertical, 2)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedSession = session
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
    
    private func formatDuration(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
    
    private func dayHasSession(_ day: Date) -> Bool {
           let cal = Calendar.current
           let startOfDay = cal.startOfDay(for: day)
           guard let endOfDay = cal.date(byAdding: .day, value: 1, to: startOfDay) else { return false }
           
           return sessions.contains { session in
               session.startTime >= startOfDay && session.startTime < endOfDay
           }
    }
    
    private var currentStreak: Int {
        let cal = Calendar.current
        var streak = 0
        var checkDate = cal.startOfDay(for: Date())
        
        if !dayHasSession(checkDate) && activeSession == nil {
            guard let yesterday = cal.date(byAdding: .day, value: -1, to: checkDate) else { return 0 }
            checkDate = yesterday
        }
        
        while dayHasSession(checkDate) {
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }
        
        return streak
    }
    
    private var daysTrackedThisWeek: Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        
        var weekStart = today
        var comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        if let ws = cal.date(from: comps) {
            weekStart = ws
        }
        
        var count = 0
        for i in 0..<7 {
            guard let day = cal.date(byAdding: .day, value: i, to: weekStart) else { continue }
            if day > today { break }
            if dayHasSession(day) { count += 1 }
        }
        
        return count
    }
    
    private var totalSessionsThisWeek: Int {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        guard let endOfToday = cal.date(byAdding: .day, value: 1, to: today) else { return 0 }
        
        var weekStart = today
        let comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        if let ws = cal.date(from: comps) {
            weekStart = ws
        }
        
        return sessions.filter { $0.startTime >= weekStart && $0.startTime < endOfToday }.count
    }
    
    private func groupedByDay(_ sessions: [TimeSession]) -> [(String, [TimeSession])] {
        let cal = Calendar.current
        var groups: [(String, [TimeSession])] = []
        var currDayString: String?
        var currGroup: [TimeSession] = []
        
        for session in sessions {
            let dayStr: String
            if cal.isDateInToday(session.startTime) {
                dayStr = "Today"
            } else if cal.isDateInYesterday(session.startTime) {
                dayStr = "Yesterday"
            } else {
                dayStr = session.startTime.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
            }
            
            if dayStr == currDayString {
                currGroup.append(session)
            } else {
                if let prevDay = currDayString {
                    groups.append((prevDay, currGroup))
                }
                currDayString = dayStr
                currGroup = [session]
            }
        }
        if let lastDay = currDayString {
            groups.append((lastDay, currGroup))
        }
        
        return groups
    }
}
