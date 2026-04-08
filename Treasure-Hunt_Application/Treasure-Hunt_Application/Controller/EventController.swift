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
    
    
    
    
    
}
