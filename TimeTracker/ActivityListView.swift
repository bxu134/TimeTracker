//
//  ActivityListView.swift
//  TimeTracker
//
//  Created by Ben Xu on 2/18/26.
//

import SwiftUI
import SwiftData

struct ActivityListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Activity.name) private var activities: [Activity]
    
    @State private var addSheet = false
    @State private var newActivityName = ""
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(activities) { activity in
                    Text(activity.name)
                        .font(.headline)
                }
                .onDelete(perform: deleteActivities)
            }
            .navigationTitle("Activities")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        addSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $addSheet) {
                NavigationStack {
                    Form {
                        if !activities.isEmpty {
                            TextField("Activity Name", text: $newActivityName)
                        } else {
                            TextField("Activity Name (e.g. Fitness)", text: $newActivityName)
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
                                saveActivity()
                            }
                            .disabled(newActivityName.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }
    
    private func saveActivity() {
        let newActivity = Activity(name: newActivityName)
        modelContext.insert(newActivity)
        newActivityName = ""
        addSheet = false
    }
    
    private func deleteActivities(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(activities[index])
        }
    }
}
