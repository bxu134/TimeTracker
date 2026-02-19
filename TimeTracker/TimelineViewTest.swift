//
//  TimelineViewTest.swift
//  TimeTracker
//
//  Created by Ben Xu on 2/18/26.
//

import SwiftUI
import SwiftData

struct TimelineViewTest: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TimeSession.startTime, order: .reverse) private var sessions: [TimeSession]
    @Query(sort: \Activity.name) private var activities: [Activity]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(sessions) { session in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(session.activity?.name ?? "Unknown Activity")
                                .font(.headline)
                            
                            if session.isRunning {
                                Text("Started at \(session.startTime.formatted(date: .omitted, time: .shortened))")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                            } else if let endTime = session.endTime {
                                Text("\(session.startTime.formatted(date: .omitted, time: .shortened)) - \(endTime.formatted(date: .omitted, time: .shortened))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        if session.isRunning {
                            Button {
                                stopSession(session)
                            } label: {
                                Image (systemName: "stop.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.title)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .onDelete(perform: deleteSessions)
            }
            .navigationTitle("Timeline")
            .safeAreaInset(edge: .bottom) {
                Menu {
                    if activities.isEmpty {
                        Text("No activites found. Add one first!")
                    } else {
                        ForEach(activities) { activity in
                            Button(activity.name) {
                                startSession(for: activity)
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "play.circle.fill")
                        Text("Start Activity")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
            }
        }
    }
    
    private func startSession(for activity: Activity) {
        withAnimation {
            let newSession = TimeSession(activity: activity)
            modelContext.insert(newSession)
        }
    }
    
    private func stopSession(_ session: TimeSession) {
        withAnimation {
            session.endTime = Date()
        }
    }
    
    private func deleteSessions(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(sessions[index])
            }
        }
    }
}
