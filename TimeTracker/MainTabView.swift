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
    
    @State private var selectedTab = 1
    
    @State private var activityToStart: Activity?
    @State private var sessionToEnd: TimeSession?
    
    @State private var addSheet = false
    @State private var newActivityName = ""
    @State private var selectedColor: Color = .blue

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
                
                DashboardView()
                    .tabItem {
                        Label("Dashboard", systemImage: "list.bullet.rectangle.fill")
                    }
                    .tag(1)
            }
            
            floatingStartButton
        }
        .sheet(isPresented: $addSheet) {
            NavigationStack {
                Form {
                    Section {
                        if !activities.isEmpty {
                            TextField("Activity Name", text: $newActivityName)
                        } else {
                            TextField("Activity Name (e.g. Fitness)", text: $newActivityName)
                        }
                    }
                    
                    Section {
                        ColorPicker("Activity Color", selection: $selectedColor, supportsOpacity: false)
                    }
                    
                }
                .navigationTitle("New Activity")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            addSheet = false
                            newActivityName = ""
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            let newActivity = Activity(name: newActivityName)
                            modelContext.insert(newActivity)
                            newActivityName = ""
                            addSheet = false
                        }
                        .disabled(newActivityName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .sheet(item: $activityToStart) { activity in
            StartSessionView(activity: activity) { goals in
                startSession(for: activity, with: goals)
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(item: $sessionToEnd) { session in
            EndSessionView(session: session) {
                stopSession(session)
            }
        }
    }
    
    @ViewBuilder
    private var floatingStartButton: some View {
        if let active = activeSession {
            Button {
                sessionToEnd = active
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
                ForEach(activities) { activity in
                    Button(activity.name) {
                        activityToStart = activity
                    }
                }
                
                Divider()
                
                Button("Create New Activity", systemImage: "plus.circle") {
                    addSheet = true
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
    
    private func startSession(for activity: Activity, with goalStrings: [String]) {
        withAnimation {
            let newSession = TimeSession(activity: activity)
            let sessionGoals = goalStrings.map { SessionGoal(text: $0) }
            newSession.goals = sessionGoals
            modelContext.insert(newSession)
            
        }
        
    }
    
    private func stopSession(_ session: TimeSession) {
        withAnimation {
            session.endTime = Date()
        }
    }
}
