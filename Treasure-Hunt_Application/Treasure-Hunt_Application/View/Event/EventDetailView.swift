//
//  EventDetailView.swift
//  Treasure-Hunt_Application
//
//  Created by Kreshnik Kona on 08/04/2026.
//

import SwiftUI

struct EventDetailView: View {
    @EnvironmentObject var eventController: EventController
    @EnvironmentObject var locationService: LocationService
    let event: Event
    
    @State private var caches: [Cache] = []
    @State private var leaderboard: [LeaderboardEntry] = []
    @State private var isJoining = false
    @State private var hasJoined = false
    @State private var showAddCache = false
    @State private var selectedTab = 0
    @State private var isLoading = false
    
    private var isOwner: Bool {
        event.eventOwnerID.value == SessionManager.shared.currentUser?.userID.value
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("Caches").tag(0)
                Text("Leaderboard").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            
            if selectedTab == 0 {
                cachesTab
            } else {
                leaderboardTab
            }
        }
        .navigationTitle(event.eventName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isOwner {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showAddCache = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showAddCache) {
            CreateCacheView(event: event) { newCache in
                caches.append(newCache)
            }
            .environmentObject(locationService)
        }
        .task { await loadData() }
    }
    
    
    
    
}
