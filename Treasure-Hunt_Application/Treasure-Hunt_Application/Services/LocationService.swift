//
//  LocationService.swift
//  Treasure-Hunt_Application
//
//  Created by Reda Ejhani on 06/04/2026.
//

import Foundation
import CoreLocation
import Combine

// MARK: - LocationService

final class LocationService: NSObject, ObservableObject {
    
    @Published var userLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var heading: CLHeading?
    
    private let manager = CLLocationManager()
    
    static let proximityThreshold: CLLocationDistance = 30
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 5
        manager.headingFilter = 5
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
    }
    
    func stopUpdating() {
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
    }
    
    func distance(to cache: Cache) -> CLLocationDistance? {
        guard let userLocation else { return nil }
        let cacheLocation = CLLocation(latitude: cache.cacheLatitude, longitude: cache.cacheLongitude)
        return userLocation.distance(from: cacheLocation)
    }
        
    func isNearby(cache: Cache) -> Bool {
        guard let dist = distance(to: cache) else { return false }
        return dist <= Self.proximityThreshold
    }
}
    
// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if manager.authorizationStatus == .authorizedWhenInUse ||
            manager.authorizationStatus == .authorizedAlways {
            startUpdating()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading
    }
    
    func locationManager (_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationService error: \(error.localizedDescription)")
    }
}
