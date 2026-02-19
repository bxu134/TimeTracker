//
//  MainTabView.swift
//  TimeTracker
//
//  Created by Ben Xu on 2/18/26.
//


import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TimeSession.startTime, order: .reverse) private var sessions: [TimeSession]
    @Query(sort: \Activity.name) private var activities: [Activity]
    
    @State private var selectedTab = 0
    
    var activeSession: TimeSession? {
        sessions.first(where: {$0.isRunning})
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView (selection: $selectedTab) {
                TimelineView()
                    .tabItem {
                        Label("Timeline", systemImage: "clock.fill")
                    }
                    .tag(0)
                
                ActivityListView()
                    .tabItem {
                        Label("Activities", systemImage: "list.bullet.rectangle.fill")
                    }
                    .tag(1)
            }
            
            floatingStartButton
        }
    }
    
    @ViewBuilder
    private var floatingStartButton: some View {
        if let active = activeSession {
            Button {
                stopSession(active)
            } label: {
                Image(systemName: "stop.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 55, height: 55)
                    .background(Color.red)
                    .clipShape(Circle())
                    .shadow(radius: 5, y: 3)
            }
            .padding(.bottom, 10)
        } else {
            Menu {
                if activities.isEmpty {
                    Text("No activities found. Add one first!")
                } else {
                    ForEach(activities) { activity in
                        Button(activity.name) {
                            startSession(for: activity)
                        }
                    }
                }
            } label: {
                Image(systemName: "play.fill")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 55, height: 55)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 5, y: 3)
            }
            .padding(.bottom, 10)
        }
    }
    
    private func startSession(for activity: Activity) {
        withAnimation {
            let newSession = TimeSession(activity: activity)
            modelContext.insert(newSession)
        }
        
        selectedTab = 0
    }
    
    private func stopSession(_ session: TimeSession) {
        withAnimation {
            session.endTime = Date()
        }
    }
}
