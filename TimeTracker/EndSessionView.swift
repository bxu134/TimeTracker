//
//  EndSessionView.swift
//  TimeTracker
//
//  Created by Ben Xu on 2/21/26.
//

import SwiftUI
import SwiftData

struct EndSessionView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var session: TimeSession
    var onSave: () -> Void
    
    @State private var newAccomplishment = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Goals Check-in") {
                    if session.goals.isEmpty {
                        Text("No goals set for this session.")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(session.goals) { goal in
                            Toggle(isOn: Bindable(goal).isCompleted) {
                                Text(goal.text)
                                    .strikethrough(goal.isCompleted)
                                    .foregroundColor(goal.isCompleted ? .secondary : .primary)
                            }
                            .toggleStyle(CheckboxToggleStyle())
                        }
                    }
                }
                
                Section("Additional Accomplishments") {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                        
                        TextField("What else did you get done?", text: $newAccomplishment)
                            .focused($isInputFocused)
                            .onSubmit {
                                addAccomplishment()
                            }
                        
                        if !newAccomplishment.isEmpty {
                            Button("Add") {
                                addAccomplishment()
                            }
                        }
                    }
                }
                
                Section("Ratings") {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Productivity")
                            Spacer()
                            Text("\(session.productivityRating)")
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        Slider(value: Binding(
                            get: {Double(session.productivityRating)},
                            set: {session.productivityRating = Int($0)}
                        ), in: 1...10, step: 1)
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Distractedness")
                            Spacer()
                            Text("\(session.distractRating)")
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        Slider(value: Binding(
                            get: {Double(session.distractRating)},
                            set: {session.distractRating = Int($0)}
                        ), in: 1...10, step: 1)
                    }
                }
                
                Section("Notes for Next Time") {
                    TextField("Notes...", text: $session.notes, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section {
                    Button {
                        onSave()
                        dismiss()
                    } label: {
                        Text("Finish Session")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Session Review")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func addAccomplishment() {
        guard !newAccomplishment.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        withAnimation {
            let newGoal = SessionGoal(text: newAccomplishment, isCompleted: true)
            session.goals.append(newGoal)
            
            newAccomplishment = ""
            isInputFocused = true
        }
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(configuration.isOn ? .green : .secondary)
                    .font(.title3)
                configuration.label
            }
        }
        .buttonStyle(.plain)
    }
}
