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

    @State private var currTime = Date()
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 0) {
                weekStrip
                        
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
            }
            .navigationTitle("Timeline")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var timeGrid: some View {
        VStack(spacing: 0) {
            ForEach(0..<25) { hour in
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
            }
        }
    }
    
    private var sessionBlocks: some View {
        ForEach(sessions) { session in
            let topOffset = calculateTopOffset(for: session)
            let blockHeight = calculateHeight(for: session)
            
            HStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.blue.opacity(0.8))
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
            .background(Color.blue.opacity(0.15))
            .cornerRadius(4)
            .clipped()
            .offset(x: 55, y: topOffset)
            .padding(.trailing, 65)
        }
    }
    
    private var weekStrip: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 15) {
                ForEach(currentWeekDates, id: \.self) { date in
                    let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
                    
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
                    }
                    .onTapGesture {
                        withAnimation {
                            selectedDate = Calendar.current.startOfDay(for: date)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .scrollIndicators(.hidden)
        .background(Color(UIColor.systemBackground))
        .shadow(color: Color.black.opacity(0.05), radius: 3, y: 3)
    }
    
    private var currentWeekDates: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (-3...3).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }
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
