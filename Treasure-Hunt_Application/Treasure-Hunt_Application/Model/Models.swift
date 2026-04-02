//
//  Models.swift
//  
//
//  Created by Abdullah Sajid on 02/04/2026.
//

import Foundation

// MARK: - FlexibleID

struct FlexibleID: Codable, Hashable, CustomStringConvertible
{
    let value: String
    var description: String { value }
    
    init(_string: String) {value = string}
    
    init(from decoder: Decoder) throws
    {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self)
        {
            value = String(intVal)
        }
        else
        {
            try container.encode(value)
        }
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.singleValueContainer()
        
        if let intVal = Int(value)
        {
            try container.encode(intVal)
        }
        else
        {
            try container.encode(value)
        }
    }
    
    var isNew: Bool { value == "0" || value.isEmpty }
}

// MARK: - User

struct User: Codable, Identifiable
{
    let userID: FlexibleID
    var userFirstname: String
    var userLastname: String
    var userPhone: String
    var userUsername: String
    var userPassword: String
    var userLatitude: Double
    var userLongitude: Double
    var userTimestamp: Double?
    var userImageURL: String?
    
    var id: String { userID.value }
    var fullName: String { "\(userFirstname) \(userLastname)"}
    
    enum CodingKeys: String, CodingKey
    {
        case userID = "UserID"
        case userFirstname = "UserFirstname"
        case userLastname = "UserLastname"
        case userPhone = "userPhone"
        case userUsername = "userUsername"
        case userPassword = "userPassword"
        case userLatitude = "userLatitude"
        case userLongitude = "userLongitude"
        case userTimestamp = "userTimestamp"
        case userImageURL = "userImageURL"
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if !userID.isNew { try container.encode(userID, forKey: .userID) }
        try container.encode(userFirstname, forKey: .userFirstname)
        try container.encode(userLastname, forKey: .userLastname)
        try container.encode(userPhone, forKey: .userPhone)
        try container.encode(userUsername, forKey: .userUsername)
        try container.encode(userPassword, forKey: .userPassword)
        try container.encode(userLatitude, forKey: .userLatitude)
        try container.encode(userLongitude, forKey: .userLongitude)
        try container.encodeIfPresent(userTimestamp, forKey: .userTimestamp)
        try container.encode(userImageURL ?? "https://placehold.co/300x300/png", forKey: .userImageURL)
    }
}
