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
    //additional variables will be needed here...

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authController)
            /// additional environmentalObjects need to be here...
        }
    }
}
