//
//  Treasure_Hunt_ApplicationApp.swift
//  Treasure-Hunt_Application
//
//  Created by Reda Ejhani on 25/03/2026.
//

import SwiftUI

@main
struct GeoQuestApp: App
{
    @StateObject private var authController = AuthController()
    @StateObject private var locationService = LocationService()
    @StateObject private var pedometerService = PedometerService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authController)
                .environmentObject(locationService)
                .environmentObject(pedometerService)
        }
    }
}
