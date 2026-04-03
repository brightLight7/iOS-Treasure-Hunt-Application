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

// MARK: - Event

struct Event: Codable, Identifiable
{
    let eventID: FlexibleID
    var eventName: String
    var eventDescription: String
    var eventOwnerID: FlexibleID
    var eventIsPublic: Bool
    var eventStart: String
    var eventFinish: String
    var eventStatusID: FlexibleID
    var eventOwner: User?
    var eventStatus: Status?
    
    var id: String {eventID.value}
    var startDate: Date? {ISO8601DateFormatter().date(from: eventStart)}
    var finishDate: Date? {ISO8601DateFormatter().date(from: eventFinish)}
    
    enum CodingKeys: String, CodingKey
    {
        case eventID = "EventID"
        var eventName = "eventName"
        var eventDescription = "eventDescription"
        var eventOwnerID = "eventOwnerID"
        var eventIsPublic = "eventIsPublic"
        var eventStart = "eventStart"
        var eventFinish = "eventFinish"
        var eventStatusID = "eventStatusID"
        var eventOwner = "eventOwner"
        var eventStatus = "eventStatus"
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if !eventID.isNew { try container.encode(eventID, forKey: .eventID) }
        
        try container.encode(eventName, forKey: .eventName)
        try container.encode(eventDescription, forKey: .eventDescription)
        try container.encode(eventOwnerID, forKey: .eventOwnerID)
        try container.encode(eventIsPublic, forKey: .eventIsPublic)
        try container.encode(eventStart, forKey: .eventStart)
        try container.encode(eventFinish, forKey: .eventFinish)
        try container.encode(eventStatusID, forKey: .eventStatusID)
    }
}

// MARK: - Status

struct Status: Codable, Identifiable
{
    let statusID: FlexibleID
    var statusName: String?
    var statusOrder: Int?
    
    var id: String { statusID?.value ?? UUID().uuidString }
    
    enum CodingKeys: String, CodingKey
    {
        case statusID = "StatusID"
        case statusName = "statusName"
        case statusOrder = "statusOrder"
    }
}
