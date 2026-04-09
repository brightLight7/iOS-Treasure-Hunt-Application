//
//  AuthController.swift
//  Treasure-Hunt_Application
//
//  Created by Abdullah Sajid on 04/04/2026.
//

import Foundation
import Combine

@MainActor
final class AuthController : ObservableObject
{
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var isLoggedIn: Bool { currentUser != nil }
    
    private let api = ApiManager.shared
    private let session = SessionManager.shared
    
    init()
    {
        currentUser = session.currentUser
    }
    
    // MARK: - Login
    
    func login(username: String, password: String) async
    {
        guard !username.isEmpty, !password.isEmpty else
        {
            errorMessage = "Please enter your username and password."
            return
        }
        isLoading = true
        errorMessage = nil
        
        /// Always check the API first to get a real numeric user ID
        if let users = try? await api.getUsers(),
           let match = users.first(where: {
               $0.userUsername.lowercased() == username.lowercased() &&
               $0.userPassword == password
           }) {
            currentUser = match
            session.currentUser = match
            isLoading = false
            return
        }
        
        /// Fallback: check locally saved user (works offline too)
        if let saved = session.currentUser,
           saved.userUsername.lowercased() == username.lowercased(),
           saved.userPassword == password {
            currentUser = saved
            isLoading = false
            return
        }
        errorMessage = "Username not found. If you just registered, tap 'Back' - you may be already logged in."
        isLoading = false
    }
    
    // MARK: - Register
    
    func register(firstname: String, lastname: String, username: String,
                  phone: String, password: String) async
    {
        guard !firstname.isEmpty, !lastname.isEmpty, !username.isEmpty, !password.isEmpty else
        {
            errorMessage = "Please fill in all fields."
            return
        }
        isLoading = true
        errorMessage = nil
        
        let newUser = User(
            userID: FlexibleID("0"), userFirstname: firstname, userLastname: lastname, userPhone: phone, userUsername: username, userPassword: password, userLatitude: 0, userLongitude: 0, userTimestamp: 0, userImageURL: "https://placehold.co/300x300/png"
        )
        
        do
        {
            let created = try await api.createUser(newUser)
            currentUser = created
            session.currentUser = created
        }
        catch
        {
            errorMessage = "Registration failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Logout
    
    func logout()
    {
        currentUser = nil
        session.logout()
    }
    
    // MARK: - Update profile
    func updateCurrentUser(_ user: User) async
    {
        isLoading = true
        do
        {
            let updated = try await api.updateUser(user)
            currentUser = updated
            session.currentUser = updated
        }
        catch
        {
            currentUser = user
            session.currentUser = user
        }
        isLoading = false
    }
}
