//
//  LoginView.swift
//  Treasure-Hunt_Application
//
//  Created by Abdullah Sajid on 05/04/2026.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authController: AuthController
    @State private var username = ""
    @State private var password = ""
    @State private var showRegister = false
    
    var body: some View
    {
        NavigationStack
        {
            ZStack
            {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 32)
                {
                    
                    VStack(spacing: 8)
                    {
                        Image(systemName: "map.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.green)
                        Text("GeoQuest")
                            .font(.largeTitle.bold())
                        Text("Find caches. Earn points. Explore.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)
                    
                    VStack(spacing: 16)
                    {
                        GQTextField(title: "Username", text: $username, icon: "person")
                        GQTextField(title: "Password", text: $password, icon: "lock", isSecure: true)
                    }
                    .padding(.horizontal)
                    
                    
                    if let err = authController.errorMessage
                    {
                        Text(err)
                            .foregroundStyle(.red)
                            .font(.caption)
                            .padding(.horizontal)
                    }
                    
                    Button
                    {
                        Task
                        {
                            await authController.login(username:
                                                        username, password: password)
                            
                        }
                    } label: {
                        Group
                        {
                            if authController.isLoading
                            {
                                ProgressView().tint(.white)
                            }
                            else
                            {
                                Text("Log In")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(authController.isLoading)
                    .padding(.horizontal)
                    
                    Button("Don't have an account? Register")
                    {
                        showRegister = true
                    }
                    .font(.footnote)
                    .foregroundStyle(.green)
                    
                    Spacer()
                }
                .navigationDestination(isPresented: $showRegister)
                {
                    RegisterView()
                }
            }
        }
    }
}
