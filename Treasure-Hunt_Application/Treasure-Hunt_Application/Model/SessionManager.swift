//
//  SessionManager.swift
//  
//
//  Created by Abdullah Sajid on 04/04/2026.
//
import Foundation

/// Persists the logged-in state to UserDefaults so the session survives app restarts.
final class SessionManager
{
    static let shared = SessionManager()
    private init() {}
    
    private let userKey = "geoquest_current_user"
    
    var currentUser : User?
    {
        get
        {
            guard let data = UserDefaults.standard.data(forKey: userKey) else { return nil }
            return try? JSONDecoder().decode(User.self, from: data)
        }
        
        set
        {
            if let user = newValue, let data = try? JSONEncoder().encode(user)
            {
                UserDefaults.standard.set(data, forKey: userKey)
            }
            else
            {
                UserDefaults.standard.removeObject(forKey: userKey)
            }
        }
    }
    func logout()
    {
        currentUser = nil
    }
}
