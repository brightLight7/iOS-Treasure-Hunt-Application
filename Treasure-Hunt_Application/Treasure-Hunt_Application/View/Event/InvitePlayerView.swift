//
//  InvitePlayerView.swift
//  Treasure-Hunt_Application
//
//  Created by Kreshnik Kona on 10/04/2026.
//

import SwiftUI

struct InvitePlayerView: View {
    let event: Event
    @Environment(\.dismiss) var dismiss

    @State private var allUsers: [User] = []
    @State private var joinedUserIDs: Set<String> = []
    @State private var isLoading = false
    @State private var invitingID: String?
    @State private var errorMessage: String?

    private var availableUsers: [User] {
        allUsers.filter {
            !joinedUserIDs.contains($0.userID.value) &&
            $0.userID.value != event.eventOwnerID.value
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading players…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if availableUsers.isEmpty {
                    ContentUnavailableView(
                        "No players to invite",
                        systemImage: "person.slash",
                        description: Text("Everyone has already joined.")
                    )
                } else {
                    List(availableUsers) { user in
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
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Invite Player")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
            .task { await loadData() }
        }
    }

    // MARK: Load

    private func loadData() async {
        isLoading = true
        do {
            async let users = ApiManager.shared.getUsers()
            async let players = ApiManager.shared.getPlayers(forEventID: event.eventID.value)
            let (fetchedUsers, fetchedPlayers) = try await (users, players)
            allUsers = fetchedUsers
            joinedUserIDs = Set(fetchedPlayers.map { $0.playerUserID.value })
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: Invite

    private func invite(_ user: User) async {
        invitingID = user.userID.value
        let player = Player(
            playerID: FlexibleID("0"),
            playerUserID: user.userID,
            playerEventID: event.eventID,
            playerUser: nil,
            playerEvent: nil
        )
        do {
            _ = try await ApiManager.shared.createPlayer(player)
            joinedUserIDs.insert(user.userID.value)
        } catch {
            errorMessage = "Failed to invite \(user.fullName)."
        }
        invitingID = nil
    }
}
