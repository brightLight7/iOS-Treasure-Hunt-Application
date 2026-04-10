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
    @State private var showEditEvent = false
    @State private var showDeleteConfirm = false
    @State private var currentEvent: Event
    @State private var cacheToEdit: Cache?
    @State private var selectedTab = 0
    @State private var isLoading = false
    @State private var players: [Player] = []
    @State private var allUsers: [User] = []
    @State private var invitingID: String?
    
    
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
                Text("Players").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()
            
            if selectedTab == 0 {
                cachesTab
            } else if selectedTab == 1 {
                leaderboardTab
            } else {
                playersTab
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
        
        
        .sheet(item: $cacheToEdit) { cache in
            EditCacheView(cache: cache) { updated in
                if let idx = caches.firstIndex(where: { $0.cacheID.value == updated.cacheID.value }) {
                    caches[idx] = updated
                }
            }
            .environmentObject(locationService)
        }
        .sheet(isPresented: $showEditEvent) {
            EditEventView(event: currentEvent) { updated in
                currentEvent = updated
            }
            .environmentObject(eventController)
        }
        .confirmationDialog("Delete Event", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                Task {
                    await eventController.deleteEvent(currentEvent)
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete \"\(currentEvent.eventName)\" and cannot be undone.")
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
    
    // MARK: Players Tab
    
    private var playersTab: some View {
        List {
            Section("Joined (\(players.count))") {
                if players.isEmpty {
                    Text("No players yet")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                } else {
                    ForEach(players) { player in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(player.playerUser?.fullName ?? "Player")
                                    .font(.headline)
                                if let username = player.playerUser?.userUsername {
                                    Text("@\(username)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            if player.playerUserID.value == currentEvent.eventOwnerID.value {
                                Spacer()
                                Text("Owner")
                                    .font(.caption.bold())
                                    .foregroundStyle(.green)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            
            if isOwner && !currentEvent.eventIsPublic {
                let joinedIDs = Set(players.map { $0.playerUserID.value })
                let uninvited = allUsers.filter { !joinedIDs.contains($0.userID.value) }
                
                Section("Invite Players") {
                    if uninvited.isEmpty {
                        Text("Everyone has been invited")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(uninvited) { user in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(user.fullName)
                                        .font(.headline)
                                    Text("@\(user.userUsername)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if invitingID == user.userID.value {
                                    ProgressView()
                                } else {
                                    Button("Invite") {
                                        Task { await invite(user) }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.green)
                                    .controlSize(.small)
                                    .disabled(invitingID != nil)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable { await loadData() }
    }
    
    // MARK: Invite
    
    private func invite(_ user: User) async {
        invitingID = user.userID.value
        let player = Player(
            playerID: FlexibleID("0"),
            playerUserID: user.userID,
            playerEventID: currentEvent.eventID,
            playerUser: nil,
            playerEvent: nil
        )
        do {
            let created = try await ApiManager.shared.createPlayer(player)
            players.append(created)
        } catch { }
        invitingID = nil
    }
    
    
    
    // MARK: Data Loading
    
    private func loadData() async {
        isLoading = true
        async let cacheLoad = ApiManager.shared.getCaches(forEventID: event.eventID.value)
        async let lbLoad = eventController.leaderboard(forEventID: event.eventID.value)
        async let playerLoad = ApiManager.shared.getPlayers(forEventID: event.eventID.value)
        if let loaded = try? await cacheLoad { caches = loaded }
        leaderboard = await lbLoad
        players = (try? await playerLoad) ?? []
        if isOwner && !currentEvent.eventIsPublic {
            allUsers = (try? await ApiManager.shared.getUsers()) ?? []
        }
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
