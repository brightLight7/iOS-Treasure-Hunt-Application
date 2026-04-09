//
//  MainTabView.swift
//  Treasure-Hunt_Application
//
//  Created by Kreshnik Kona on 09/04/2026.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authController: AuthController
    @StateObject private var mapController = MapController()
    @StateObject private var eventController = EventController()
    
    var body: some View {
        TabView {
            MapView()
                .environmentObject(mapController)
                .tabItem {
                    Label("Explore", systemImage: "map.fill")
                }
            
            EventListView()
                .environmentObject(eventController)
                .tabItem {
                    Label("Events", systemImage: "flag.2.crossed.fill")
                }
            
            LeaderboardView()
                .tabItem {
                    Label("Leaderboard", systemImage: "trophy.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tint(.green)
    }
}
