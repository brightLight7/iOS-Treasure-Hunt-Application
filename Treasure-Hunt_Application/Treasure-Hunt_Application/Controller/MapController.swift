//
//  MapController.swift
//  Treasure-Hunt_Application
//
//  Created by Reda Ejhani on 06/04/2026.
//

import Foundation
import MapKit
import Combine

// MARK: - MapController

@MainActor
final class MapController: ObservableObject {
    
    @Published var caches: [CacheWithStatus] = []
    @Published var selectedCache: Cache?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.4123, longitude: -0.3008),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    
    private let api = ApiManager.shared
    private let session = SessionManager.shared
    private var locationService: LocationService?
    
    func setup(locationService: LocationService) {
        self.locationService = locationService
    }
    
    // MARK: - Load global caches
    
    func loadGlobalCaches() async {
        isLoading = true
        errorMessage = nil
        do {
            let allCaches = try await api.getCaches()
            let allFinds = try await fetchCurrentPlayerFinds()
            let foundCacheIDs = Set(allFinds.map { $0.findCacheID.value })
            
            caches = allCaches.map { cache in
                let find = allFinds.first { $0.findCacheID.value == cache.cacheID.value }
                return CacheWithStatus(cache: cache, isFound: foundCacheIDs.contains(cache.cacheID.value), find: find)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // MARK: - Load event caches
    
    func loadCaches(forEventID eventID: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let eventCaches = try await api.getCaches(forEventID: eventID)
            let allFinds = try await fetchCurrentPlayerFinds()
            let foundCacheIDs = Set(allFinds.map { $0.findCacheID.value })
            
            caches = eventCaches.map { cache in
                let find = allFinds.first { $0.findCacheID.value == cache.cacheID.value }
                return CacheWithStatus(cache: cache, isFound: foundCacheIDs.contains(cache.cacheID.value), find: find)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    // MARK: - Proximity check
    
    func canUnlock(cache: Cache) -> Bool {
        guard let locationService,
              let dist = locationService.distance(to: cache) else { return false }
        let stored = UserDefaults.standard.double(forKey: "proximity_\(cache.cacheID.value)")
        let threshold = stored > 0 ? stored : 30.0
        return dist <= threshold
    }
    
    // MARK: - Log a find
    
    func logFind(for cache: Cache, imageURL: String? = nil) async -> Bool {
        guard let user = session.currentUser else {
            errorMessage = "Not logged in"
            return false
        }
        
        guard let pid = await resolvePlayerID(forUserID: user.userID.value, eventID: cache.cacheEventID.value) else {
            errorMessage = "Could not resolve player - try joining the event first"
            return false
        }
        
        let find = Find(
            findID: FlexibleID("0"),
            findPlayerID: FlexibleID(pid),
            findCacheID: cache.cacheID,
            findDatetime: ISO8601DateFormatter().string(from: Date()),
            findImageURL: imageURL ?? "https://placehold.co/300x300/png",
            findPlayer: nil,
            findCache: nil
            )
        do {
            let created = try await api.createFind(find)
            if let idx = caches.firstIndex(where: { $0.cache.cacheID.value == cache.cacheID.value}) {
                caches[idx].isFound = true
                caches[idx].find = created
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    // MARK: - Centre map on user
    
    func centreOnUser() {
        guard let loc = locationService?.userLocation else { return }
        mapRegion = MKCoordinateRegion(
            center: loc.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
    
    // MARK: - Private helpers
    
    private func fetchCurrentPlayerFinds() async throws -> [Find] {
        guard let user = session.currentUser else { return [] }
        let players = try await api.getPlayers()
        let myPlayerIDs = players.filter { $0.playerUserID.value == user.userID.value }.map { $0.playerID.value }
        var finds: [Find] = []
        for pid in myPlayerIDs {
            let pFinds = try await api.getFinds(forPlayerID: pid)
                                            finds.append(contentsOf: pFinds)
        }
        return finds
    }
    
    private func resolvePlayerID(forUserID userID: String, eventID: String) async -> String? {
        do {
            let players = try await api.getPlayers(forEventID: eventID)
            if let p = players.first(where: { $0.playerUserID.value == userID }) {
                return p.playerID.value
            }
                                                   
            let newPlayer = Player(
                playerID: FlexibleID("0"),
                playerUserID: FlexibleID(userID),
                playerEventID: FlexibleID(eventID),
                playerUser: nil,
                playerEvent: nil
            )
            
            let created = try await api.createPlayer(newPlayer)
            return created.playerID.value
        } catch {
            return nil
        }
    }
}

