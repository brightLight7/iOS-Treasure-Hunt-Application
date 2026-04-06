//
//  Extensions.swift
//  Treasure-Hunt_Application
//
//  Created by Reda Ejhani on 06/04/2026.
//

import Foundation
import CoreLocation

// MARK: - Bearing calculator

extension CLLocationCoordinate2D {
    
    func bearing(to destination: CLLocationCoordinate2D) -> Double {
        let lat1 = latitude.toRadians()
        let lon1 = longitude.toRadians()
        let lat2 = destination.latitude.toRadians()
        let lon2 = destination.longitude.toRadians()
        
        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let bearing = atan2(y, x).toDegrees()
        return (bearing + 360).truncatingRemainder(dividingBy: 360)
    }
}

extension Double {
    func toRadians() -> Double { self * .pi / 180 }
    func toDegrees() -> Double { self * 180 / .pi }
    
    var formattedDistance: String {
        self < 1000
        ? String(format: "%.0f m", self)
        : String(format: "%.1f km", self / 1000)
    }
}

// MARK: - Data helpers

extension Data {
    var iso8601String: String {
        ISO8601DateFormatter().string(from: self)
    }
}

