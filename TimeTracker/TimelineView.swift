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

    
    var body: some View {
        NavigationStack{
            VStack(spacing: 0) {
                weekStrip
                        
                
                ScrollView { // placeholder for actual timeline
                    VStack {
                        Spacer().frame(height: 100)
                        Text("Timeline")
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Timeline")
            .navigationBarTitleDisplayMode(.inline)
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
    

}
