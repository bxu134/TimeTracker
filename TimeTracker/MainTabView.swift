//
//  MainTabView.swift
//  TimeTracker
//
//  Created by Ben Xu on 2/18/26.
//


import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            TimelineView()
                .tabItem {
                    Label("Timeline", systemImage: "clock.fill")
                }
            
            ActivityListView()
                .tabItem {
                    Label("Activities", systemImage: "list.bullet.rectangle.fill")
                }
        }
    }
}
