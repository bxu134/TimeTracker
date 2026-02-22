//
//  ActivityListView.swift
//  TimeTracker
//
//  Created by Ben Xu on 2/22/26.
//

import SwiftUI
import SwiftData

struct ActivityListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Activity.name) private var activities: [Activity]
    
    @State private var activityToEdit: Activity?
    
    var onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Activity List")
                    .font(.headline)
                
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            
            Divider()
            
            if activities.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "list.dash")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No activities found.")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 4) {
                        ForEach(activities) { activity in
                            activityRow(activity)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: 340, maxHeight: 500)
        .background(Color(UIColor.systemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.2), radius: 15, x:0, y: 8)
        .sheet(item: $activityToEdit) { activity in
            EditActivityView(activity: activity)
        }
    }
    
    @ViewBuilder
    private func activityRow(_ activity: Activity) -> some View {
        Button {
            activityToEdit = activity
        } label : {
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color(hex: activity.hexColor))
                    .frame(width: 12)
                
                HStack {
                    Text(activity.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.body.weight(.bold))
                        .foregroundColor(Color(hex: activity.hexColor))
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 50)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
    
    private func deleteActivities(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(activities[index])
            }
        }
    }
}

struct EditActivityView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var activity: Activity
    
    @State private var draftName = ""
    @State private var draftColor: Color = .blue
    
    @State private var confirmDelete = false
    @State private var confirmDeleteHistory = false
    @Query private var allSessions: [TimeSession]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Activity Details") {
                    TextField("Name", text: $draftName)
                    ColorPicker("Color", selection: $draftColor, supportsOpacity: false)
                }
                
                Section {
                    Button(role: .destructive) {
                        confirmDeleteHistory = true
                    } label : {
                        Text("Delete All History")
                            .frame(maxWidth: .infinity)
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        confirmDelete = true
                    } label : {
                        Text("Delete Activity")
                            .frame(maxWidth: .infinity)
                    }
                }
                
                
            }
            .navigationTitle("Edit Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        activity.updateDetails(newName: draftName, newColor: draftColor)
                        dismiss()
                    }
                    .disabled(draftName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                draftName = activity.name
                draftColor = activity.color
            }
            .confirmationDialog("Delete All Session History?", isPresented: $confirmDeleteHistory, titleVisibility: .visible) {
                Button("Delete All History", role: .destructive) {
                    let history = allSessions.filter { $0.activity == activity }
                    
                    for session in history {
                        modelContext.delete(session)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permananently delete ALL past sessions for \(activity.name). The activity will not be deleted")
            }
            .confirmationDialog("Delete \(activity.name)?", isPresented: $confirmDelete, titleVisibility: .visible) {
                Button("Delete", role: .destructive) {
                    modelContext.delete(activity)
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete this activity.")
            }
        }
        .presentationDetents([.medium])
    }
}
