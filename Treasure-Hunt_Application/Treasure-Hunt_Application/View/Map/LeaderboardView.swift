//
//  LeaderboardView.swift
//  Treasure-Hunt_Application
//
//  Created by Kreshnik Kona on 09/04/2026.
//

import SwiftUI

struct LeaderboardView: View {
    @State private var entries: [LeaderboardEntry] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading leaderboard…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else if entries.isEmpty {
                    ContentUnavailableView(
                        "No scores yet",
                        systemImage: "trophy",
                        description: Text("Find some caches to appear here!")
                    )
                } else {
                    List {
                        // Top 3 podium
                        if entries.count >= 3 {
                            Section {
                                PodiumView(entries: Array(entries.prefix(3)))
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(EdgeInsets())
                            }
                        }
                        
                        // Full ranking list
                        Section("All Players") {
                            ForEach(Array(entries.enumerated()), id: \.element.id)
                            { idx, entry in LeaderboardRowView(entry: entry, rank: idx + 1)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Leaderboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await load() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .task { await load() }
            .refreshable { await load() }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }
    
    private func load() async {
        isLoading = true
        errorMessage = nil
        do {
            let api = ApiManager.shared
            async let allPlayers = api.getPlayers()
            async let allFinds = api.getFinds()
            async let allCaches = api.getCaches()
            let (players, finds, caches) = try await (allPlayers, allFinds, allCaches)
            
            let cachePointsMap = Dictionary(uniqueKeysWithValues: caches.map {
                ($0.cacheID, $0.cachePoints) })
            
            // Calculating the points per player
            entries = players.map { player in
                let playerFinds = finds.filter { $0.findPlayerID == player.playerID
                }
                let points = playerFinds.reduce(0.0) { $0 + (cachePointsMap[$1.findCacheID] ?? 0) }
                return LeaderboardEntry(player: player, totalPoints: points, findCount: playerFinds.count)
            }
            .filter { $0.findCount > 0 }
            .sorted { $0.totalPoints > $1.totalPoints }
            
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
                                
