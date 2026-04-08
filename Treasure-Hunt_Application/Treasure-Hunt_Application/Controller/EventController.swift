//
//  EventController.swift
//  
//
//  Created by Kreshnik Kona on 08/04/2026.
//

import Foundation
import Combine

// MARK: Event Controller
// The MVC Controller manages the event CRUD, players joining and the leaderboard data
// The views observe the @Published properties and react to changes

@MainActor
final class EventController: ObservableObject {
    
    @Published var event: [Event] = []
    @Published var myEvents: [Event] = []
    @published var statuses: [Status] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let api = ApiManager.shared
    private let session = SessionManager.shared
    
    // MARK: Load every event and status
    
    func loadAll() async {
        isLoading = true
        errorMessage = nil
        async let allEvents = api.getEvents()
        async let allStatuses = api.getStatuses()
        do {
            let (evts, stats) = try await (allEvents, allStatuses)
            events = evts
            statuses = stats
            if let user = session.currentUser {
                myEvents = evts.filter { $0.eventOwnerID.value ==
                    user.userID.value }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // MARK: Create event
    
    func createEvent(name: String, description: String, start: Date,finish: Date, isPublic: Bool) async -> Event? {
        guard let user = session.currentUser else { return nil }
        
        // Load statuses if not yet available; fall back to ID "130" (the live API default)
        if statuses.isEmpty {
            if let loaded = try? await api.getStatuses(), !loaded.isEmpty {
                statuses = loaded
            }
        }
        let statusID = statuses.first?.statusID ?? FlexibleID("130")
        
        let fmt = ISO8601DateFormatter()
        let event = Event(
            eventID: FlexibleID("0"),
            eventName: name,
            eventDescription: description,
            eventOwnerID: user.userID,
            eventIsPublic: isPublic,
            eventStart: fmt.string(from: start),
            eventFinish: fmt.string(from: finish),
            eventStatusID: statusID,
            eventOwner: nil,
            eventStatus: nil
        )
        do {
            let created = try await api.createEvent(event)
            events.append(created)
            myEvents.append(created)
            
            // Makes the owner as player 1
            let player = Player(
                playerID: FlexibleID("0"),
                playerUserID: user.userID,
                playerEventID: created.eventID,
                playerUser: nil,
                playerEvent: nil
            )
            _ = try? await api.createPlayer(player)
            
            return created
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
            
        
    
    
    
}
