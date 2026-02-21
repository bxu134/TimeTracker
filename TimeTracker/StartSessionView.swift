//
//  StartSessionView.swift
//  TimeTracker
//
//  Created by Ben Xu on 2/21/26.
//

import SwiftUI

struct LocalGoal: Identifiable {
    let id = UUID()
    var text: String
}

struct StartSessionView: View {
    @Environment(\.dismiss) private var dismiss
    var activity: Activity
    
    var onStart: ([String]) -> Void
    
    @State private var newGoalText = ""
    @FocusState private var isInputFocused: Bool
    
    @State private var goals: [LocalGoal] = []
    
    private var prevNotes: String? {
        guard let pastSessions = activity.sessions, !pastSessions.isEmpty else { return nil }
        
        let mostRecent = pastSessions.sorted { $0.startTime > $1.startTime } .first
        
        if let notes = mostRecent?.notes {
            let cleanedNote = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            if !cleanedNote.isEmpty {
                return cleanedNote
            }
        }
        
        return nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Circle()
                            .fill(activity.color)
                            .frame(width: 12, height: 12)
                        Text("Starting \(activity.name)")
                            .font(.headline)
                    }
                }
                
                if let oldNotes = prevNotes {
                    Section("Notes from Last Time") {
                        Text(oldNotes)
                            .foregroundColor(.secondary)
                            .fontWeight(.bold)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                Section("Session Goals") {
                    ForEach($goals) { $goal in
                        HStack {
                            Image(systemName: "circle")
                                .foregroundColor(.secondary)
                            TextField("Edit goal", text: $goal.text)
                        }
                    }
                    .onDelete { indexSet in
                        goals.remove(atOffsets: indexSet)
                    }
                    
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                        
                        TextField("Add a goal...", text: $newGoalText)
                            .focused($isInputFocused)
                            .onSubmit {
                                addGoal()
                            }
                        
                        if !newGoalText.isEmpty {
                            Button("Add") {
                                addGoal()
                            }
                        }
                    }
                }
                
                Section {
                    Button {
                        let goalStrings = goals.map { $0.text }
                        onStart(goalStrings)
                        dismiss()
                    } label: {
                        Text("Start Session")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.bold)
                    }
                }
            }
            .navigationTitle("Set Objectives")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func addGoal() {
        guard !newGoalText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        withAnimation {
            goals.append(LocalGoal(text: newGoalText))
            newGoalText = ""
            isInputFocused = true
        }
    }
    
}
