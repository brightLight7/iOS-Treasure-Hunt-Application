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

// MARK: - Player

struct Player: Codable, Identifiable
{
    let playerID: FlexibleID
    var playerUserID: FlexibleID
    var playerEventID: FlexibleID
    var playerUser: User?
    var playerEvent: User?
    
    var id: String { playerID.value }
    
    enum CodingKeys: String, CodingKey
    {
        case playerID = "PlayerID"
        case playerUserID = "playerUserID"
        case playerEventID = "playerEventID"
        case playerUser = "playerUser"
        case playerEvent = "playerEvent"
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if !playerID.isNew { try container.encode(playerID, forKey: .playerID) }
        try container.encode(playerUserID, forKey: .playerUserID)
        try container.encode(playerEventID, forKey: .playerEventID)
    }
}

// MARK: - Cache

struct Cache: Codable, Identifiable
{
    let cacheID: FlexibleID
    var cacheName: String
    var cacheDescription: String
    var cacheEventID: FlexibleID
    var cacheImageURL: String
    var cacheClue: String
    var cachePoints: String
    var cacheLatitude: String
    var cacheLongitude: String
    var cacheEvent: Event?
    
    var id: String { cacheID.value }
    
    enum CodingKeys: String, CodingKey
    {
        case cacheID = "cacheID"
        case cacheName = "cacheName"
        case cacheDescription = "cacheDescription"
        case cacheEventID = "cacheEventID"
        case cacheImageURL = "cacheImageURL"
        case cacheClue = "cacheClue"
        case cachePoints = "cachePoints"
        case cacheLatitude = "cacheLatitude"
        case cacheLongitude = "cacheLongitude"
        case cacheEvent = "cacheEvent"
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if !cacheID.isNew { try container.encode(cacheID, forKey: .cacheID) }
        
        try container.encode(cacheName, forKey: .cacheName)
        try container.encode(cacheDescription, forKey: .cacheDescription)
        try container.encode(cacheEventID, forKey: .cacheEventID)
        try container.encode(cacheImageURL ?? "https://placehold.co/300x300/png", forKey: .cacheImageURL)
        try container.encode(cacheClue, forKey: .cacheClue)
        try container.encode(cachePoints, forKey: .cachePoints)
        try container.encode(cacheLatitude, forKey: .cacheLatitude)
        try container.encode(cacheLongitude, forKey: .cacheLongitude)
        try container.encode(cacheEvent, forKey: .cacheEvent)
    }
}

// MARK: - Find

struct Find: Codable, Identifiable
{
    let findID: FlexibleID
    var findPlayerID: FlexibleID
    var findCacheID: FlexibleID
    var findDatetime: String
    var findImageURL: String?
    var findPlayer: Player?
    var findCache: Cache?
    
    var id: String { findID.value }
    var findDate: Date? {ISO8601DateFormatter().date(from: findDatetime)}
    
    enum CodingKeys: String, CodingKey
    {
        case findID = "findID"
        case findPlayerID = "findPlayerID"
        case findCacheID = "findCacheID"
        case findDatetime = "findDatetime"
        case findImageURL = "findImageURL"
        case findPlayer = "findPlayer"
        case findCache = "findCache"
    }
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if !cacheID.isNew { try container.encode(findID, forKey: .findID) }
        
        try container.encode(findPlayerID, forKey: .findPlayerID)
        try container.encode(findCacheID, forKey: .findCacheID)
        try container.encode(findDatetime, forKey: .findDatetime)
        try container.encode(findImageURL ?? "https://placehold.co/300x300/png", forKey: .findImageURL)
    }
}
