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
    private let locationService: LocationService?
    private var playerID: String?
    
    func setup(locationService: LocationService) {
        self.locationService = locationService
    }
}

