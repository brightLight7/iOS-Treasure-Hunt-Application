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
    @State private var showDeleteConfirm = false
    @State private var currentEvent: Event
    @State private var cacheToEdit: Cache?
    @State private var selectedTab = 0
    @State private var isLoading = false
    
    init(event: Event) {
        self.event = event
        _currentEvent = State(initialValue: event)
    }
    
    // MARK: Cache tab
    private var isOwner: Bool {
        event.eventOwnerID.value == SessionManager.shared.currentUser?.userID.value
    }
    
    @Environment(\.dismiss) var dismiss
    
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
        .navigationTitle(currentEvent.eventName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if isOwner {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button { showAddCache = true } label: {
                            Label("Add Cache", systemImage: "plus")
                        }
                        Button { showEditEvent = true } label: {
                            Label("Edit Event", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            Label("Delete Event", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showAddCache) {
            CreateCacheView(event: currentEvent) { newCache in
                caches.append(newCache)
            }
            .environmentObject(locationService)
        }
        .task { await loadData() }
    }
    
    // MARK: Cache Tab
    
    private var cachesTab: some View {
        List {
            if !isOwner {
                Section {
                    Button {
                        Task {
                            isJoining = true
                            hasJoined = await eventController.joinEvent(event)
                            isJoining = false
                        }
                    } label: {
                        HStack {
                            if isJoining { ProgressView() }
                            Text(hasJoined ? "Joined ✓" : "Join Event") .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                    }
                    .disabled(hasJoined)
                    .foregroundStyle(hasJoined ? .secondary : Color.green)
                }
            }
            
            Section("Caches (\(caches.count))") {
                if caches.isEmpty {
                    Text("No caches added yet")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                } else {
                    ForEach(caches) { cache in CacheRowView(cache: cache)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                if isOwner {
                                    Button {
                                        cacheToEdit = cache
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.blue)
                                }
                            }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable { await loadData() }
    }
    
    // MARK: Leaderboard Tab
    
    private var leaderboardTab: some View {
        List {
            if leaderboard.isEmpty {
                Text("No scores yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(leaderboard.enumerated()), id: \.element.id) { idx, entry in LeaderboardRowView(entry: entry, rank: idx + 1)
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            leaderboard = await eventController.leaderboard(forEventID: event.eventID.value)
        }
    }
    
    
    // MARK: Data Loading
    
    private func loadData() async {
        isLoading = true
        async let cacheLoad = ApiManager.shared.getCaches(forEventID: event.eventID.value)
        async let lbLoad = eventController.leaderboard(forEventID: event.eventID.value)
        if let loaded = try? await cacheLoad { caches = loaded }
        leaderboard = await lbLoad
        isLoading = false
    }
}
    
// MARK: Cache row

struct CacheRowView: View {
    let cache: Cache
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(cache.cacheName).font(.headline)
            Text(cache.cacheDescription).font(.subheadline).foregroundStyle(.secondary).lineLimit(1)
            Text("\(Int(cache.cachePoints)) pts").font(.caption).foregroundStyle(Color.green)
        }
        .padding(.vertical, 2)
    }
}

// MARK: Leaderboard row

struct LeaderboardRowView: View {
    let entry: LeaderboardEntry
    let rank: Int
    
    var body: some View {
        HStack(spacing: 14) {
            Text("\(rank)")
                .font(.title3.bold())
                .foregroundStyle(rankColor)
                .frame(width: 32)
            
            VStack(alignment: .leading) {
                Text(entry.player.playerUser?.fullName ?? "Player")
                    .font(.headline)
                Text("\(entry.findCount) finds")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            
            Text("\(Int(entry.totalPoints)) pts")
                .font(.headline)
                .foregroundStyle(Color.green)
        }
        .padding(.vertical, 4)
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return Color(.systemGray)
        case 3: return .orange
        default: return .secondary
        }
    }
}
