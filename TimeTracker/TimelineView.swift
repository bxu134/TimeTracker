//
//  TimelineView.swift
//  TimeTracker
//
//  Created by Ben Xu on 2/19/26.
//

import SwiftUI
import SwiftData

struct TimelineView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TimeSession.startTime, order: .reverse) private var sessions: [TimeSession]
    
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var weekOffset: Int = 0
    
    @State private var currTime = Date()
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    private var filteredSessions: [TimeSession] {
        let startOfDay = selectedDate
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return sessions.filter { session in
            let sessionEnd = session.endTime ?? currTime
            return session.startTime < endOfDay && sessionEnd > startOfDay
        }
    }
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 0) {
                weekStrip
                        
                ScrollViewReader { proxy in
                    ScrollView {
                        ZStack(alignment: .topLeading) {
                            timeGrid
                            sessionBlocks
                        }
                        .frame(height: 1440)
                        .padding(.top, 20)
                        .padding(.bottom, 100)
                    }
                    .onReceive(timer) { input in
                        currTime = input
                    }
                    .onAppear {
                        scrollToInitialTime(proxy: proxy)
                    }
                    .onChange(of: selectedDate) { _, _ in
                        scrollToInitialTime(proxy: proxy)
                    }

                    
                }
            }
            .navigationTitle("Timeline")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var timeGrid: some View {
        VStack(spacing: 0) {
            ForEach(0..<25, id: \.self) { hour in
                HStack(alignment: .top) {
                    Text(formatHour(hour))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(width: 50, alignment: .trailing)
                        .offset(y: -7)
                    
                    VStack() {
                        Divider()
                    }
                }
                .frame(height: 60, alignment: .top)
                .id(hour)
            }
        }
    }
    
    private var sessionBlocks: some View {
        ForEach(filteredSessions) { session in
            let topOffset = calculateTopOffset(for: session)
            let blockHeight = calculateHeight(for: session)
            
            let activityColor = session.activity?.color ?? .gray
            
            HStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(activityColor.opacity(0.8))
                    .frame(width: 4)
                    .padding(.vertical, blockHeight > 12 ? 4 : 0)
                if blockHeight > 15 {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(session.activity?.name ?? "Unknown")
                            .font(.caption)
                            .fontWeight(.bold)
                            .lineLimit(1)
                        if blockHeight > 30 {
                            Text("\(session.startTime.formatted(date: .omitted, time: .shortened))")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 4)
                }
                Spacer()
            }
            .padding(.horizontal, 6)
            .frame(height: blockHeight, alignment: .top)
            .background(activityColor.opacity(0.15))
            .cornerRadius(4)
            .clipped()
            .offset(x: 55, y: topOffset)
            .padding(.trailing, 65)
        }
    }
    
    private var weekStrip: some View {
        TabView(selection: $weekOffset) {
            ForEach(-26...26, id: \.self) { offset in
                HStack(spacing: 0) {
                    ForEach(weekDates(for: offset), id: \.self) { date in
                        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                        let isToday = Calendar.current.isDateInToday(date)
                        
                        VStack(spacing: 5) {
                            Text(date.formatted(.dateTime.weekday(.abbreviated)))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(isSelected ? .blue : .secondary)
                            
                            Text(date.formatted(.dateTime.day()))
                                .font(.title3)
                                .fontWeight(isSelected ? .bold : .regular)
                                .foregroundColor(isSelected ? .white : .primary)
                                .frame(width: 40, height: 40)
                                .background(isSelected ? Color.blue : Color.clear)
                                .clipShape(Circle())
                                .overlay(alignment: .bottom) {
                                    if isToday {
                                        Circle()
                                            .fill(isSelected ? Color.white : Color.blue)
                                            .frame(width: 4, height: 4)
                                            .padding(.bottom, 5)
                                    }
                                }
                        }
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                selectedDate = Calendar.current.startOfDay(for: date)
                            }
                        }
                    }
                }
                .tag(offset)
            }
        }
        .frame(height: 80)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .background(Color(UIColor.systemBackground))
        .shadow(color: Color.black.opacity(0.05), radius: 3, y: 3)
    }
    
    private func weekDates( for offset: Int) -> [Date] {
        var cal = Calendar.current
        cal.firstWeekday = 2
        
        let today = cal.startOfDay(for: Date())
        let currWeekStart = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        
        let targetWeek = cal.date(byAdding: .weekOfYear, value: offset, to: currWeekStart)!
        
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: targetWeek) }
    }
    
    private func scrollToInitialTime(proxy: ScrollViewProxy) {
        if Calendar.current.isDateInToday(selectedDate) {
            let currentHour = Calendar.current.component(.hour, from: Date())
            
            let targetHour = max(0, currentHour - 2)
            withAnimation {
                proxy.scrollTo(targetHour, anchor: .top)
            }
        } else {
            withAnimation {
                proxy.scrollTo(8, anchor: .top)
            }
        }
    }
    
    private func formatHour(_ hour: Int) -> String {
            if hour == 0 || hour == 24 { return "12 AM" }
            if hour == 12 { return "12 PM" }
            return hour < 12 ? "\(hour) AM" : "\(hour - 12) PM"
    }
    
    private func calculateTopOffset(for session: TimeSession) -> CGFloat {
        let startOfDay = selectedDate
        let actualStart = max(session.startTime,  startOfDay)
        
        let minSinceMidnight = actualStart.timeIntervalSince(startOfDay) / 60
        return CGFloat(minSinceMidnight)
    }
    
    private func calculateHeight(for session: TimeSession) -> CGFloat {
        let startOfDay = selectedDate
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let actualStart = max(session.startTime, startOfDay)
        let actualEnd = min(session.endTime ?? currTime, endOfDay)
        
        let durationInMinutes = actualEnd.timeIntervalSince(actualStart) / 60
        return max(CGFloat(durationInMinutes), 2)
    }
    
}
