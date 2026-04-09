//
//  ProfileView.swift
//  Treasure-Hunt_Application
//
//  Created by Kreshnik Kona on 09/04/2026.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authController: AuthController
    @State private var myFinds: [Find] = []
    @State private var totalPoints: Double = 0
    @State private var isLoading = false
    @State private var showEditProfile = false
    
    private var user: User? { authController.currentUser }\
    
    var body: some View {
        NavigationStack {
            List {
                // Avatar and name header
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Color.green.opacity(0.2))
                                .frame(width: 64, height: 64)
                            Text(initials)
                                .font(.title2.bold())
                                .foregroundStyle(.green)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(user?.fullName ?? "")
                                .font(.title3.bold())
                            Text("@\(user?.userUsername ?? "")")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }
                
                // Stats
                Section("Stats") {
                    StatRow(icon: "checkmark.circle.fill", color: .green,
                            label: "Caches Found", value: "\(myFinds.count)")
                    StatRow(icon: "star.fill", color: .yellow, label: "Total Points", value: "\(Int(totalPoints))")
                }
                
                // Recent finds
                if !myFinds.isEmpty {
                    Section("Recent Finds") {
                        ForEach(myFinds.prefix(5)) { find in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(find.findCache?.cacheName ?? "Cache")
                                    .font(.subheadline)
                                if let date = find.findDate {
                                    Text(date, style: .relative)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                
                // Actions
                Section {
                    Button {
                        showEditProfile = true
                    } label: {
                        Label("Edit Profile", systemImage: "person.badge.plus")
                    }
                    
                    Button(role: .destructive) {
                        authController.logout()
                    } label: {
                        Label("Log Out", systemImage:
                                "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Profile")
            .task { await loadStats() }
            .sheet(isPresented: $showEditProfile) {
                EditProfileView()
                    .environmentObject(authController)
            }
        }
    }
    
    private var initials: String {
        let first = user?.userFirstname.first.map(String.init) ?? ""
        let last  = user?.userLastname.first.map(String.init) ?? ""
        return first + last
    }
    
    private func loadStats() async {
        guard let user = authController.currentUser else { return }
        isLoading = true
        do {
            let api = ApiManager.shared
            let allPlayers = try await api.getPlayers()
            let myPlayerIDs = allPlayers.filter { $0.playerUserID.value == user.userID.value }.map { $0.playerID.value }
            
            var finds: [Find] = []
            for pid in myPlayerIDs {
                let pFinds = try await api.getFinds(forPlayerID: pid)
                finds.append(contentsOf: pFinds)
            }
            myFinds = finds.sorted { ($0.findDate ?? .distantPast) > ($1.findDate ?? .distantPast) }
            
            let allCaches = try await api.getCaches()
            let cachePoints = Dictionary(uniqueKeysWithValues: allCaches.map {
                ($0.cacheID.value, $0.cachePoints) })
            totalPoints = myFinds.reduce(0.0) { $0 + (cachePoints[$1.findCacheID.value] ?? 0) }
        } catch {
            print("Profile load error: \(error)")
        }
        isLoading = false
    }
}


