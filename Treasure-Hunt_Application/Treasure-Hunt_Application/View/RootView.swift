//
//  RootView.swift
//  Treasure-Hunt_Application
//
//  Created by Abdullah Sajid on 05/04/2026.
//

import SwiftUI

struct RootView: View
{
    @EnvironmentObject var authController: AuthController
    var body: some View
    {
        Group
        {
            if authController.isLoggedIn
            {
                // correct file goes here...
            }
            else
            {
                LoginView()
            }
        }
        .animation(.easeOut, value: authController.isLoggedIn)
        
    }
}
