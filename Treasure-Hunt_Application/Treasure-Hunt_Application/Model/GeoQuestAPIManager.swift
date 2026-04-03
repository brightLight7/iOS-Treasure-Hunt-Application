//
//  GeoQuestAPIManager.swift
//  
//
//  Created by Abdullah Sajid on 03/04/2026.
//

import Foundation

// MARK: - API Error

enum APIError: LocalizedError
{
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(Int)
    case networkError(Error)
    case unauthorized
    
    var errorDescription: String?
    {
        switch self
        {
            case .invalidURL:            return "Invalid URL"
            case .noData:                return "No data received"
            case .decodingError(let e):  return "Decoding error: \(e.localizedDescription)"
            case .serverError(let code): return "Server error: \(code)"
            case .networkError(let e):   return e.localizedDescription
            case .unauthorized:          return "Unauthorized - please log in again"
            
            
        }
    }
}

// MARK: - Flexible response wrappers

private struct WrappedArray<T: Decodable>: Decodable
{
    let values: [T]
    init (from decoder: Decoder) throws
    {
        if let arr = try? [T] (from: decoder)
        {
            values = arr
            return
        }
        
        let container = try decoder.container(keyedBy: DynamicKey.self)
        for key in container.allKeys
        {
            if let arr = try? container.decode([T].self, forKey: key)
            {
                values = arr
                return
            }
        }
        values = []
        
    }
}

private struct WrappedSingle<T: Decodable>: Decodable
{
    let value: T
    init (from: decoder: Decoder) throws
    {
        if let arr = try? [T](from: decoder), let first = arr.first
        {
            value = first
            return
        }
        if let v = try? T(from decoder)
        {
            value = v
            return
        }
        let container = try decoder.container(keyedBy: DynamicKey.self)
        for key in container.allKeys
        {
            if let v = try? container.decode(T.self, forKey: key)
            {
                value = v
                return
            }
        }
        throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Could not decode wrapped single"))
    }
}

private struct DynamicKey: CodingKey
{
    var stringValue: String
    var intValue: Int?
    init?(stringValue: String) { self.stringValue = stringValue }
    init?(intValue: Int) { self.intValue = intValue; self.stringValue = "\(intValue)" }
}

// MARK: - API Manager

final class ApiManager
{
    static let shared = APIManager()
    private int() {}
    
    private let apiKey = "aqnev4"
    private let baseURL = "https://mark0s.com/geoquest/v1/api"
    
    private var urlSession: URLSession =
    {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        return URLSession(configuration: config)
    }()
    
    
    // MARK: - URL Builder
    private func makeURL(_ path: String, extraParams: [String: String] = [:]) throws -> URL
    {
        var components = URLComponents(string: baseURL + path)
        var queryItems = [URLQueryItem(name: "key", value: apiKey)]
        extraParams.forEach { queryItems.append(URLQueryItem(name: $0.key, value: $0.value)) }
        components?.queryItems = queryItems
        guard let url = components?.url else { throw APIError.invalidURL }
        return url
    }
    
    // MARK: - Raw data fetch
    
    private func fetchData(_ request: URLRequest) async throws -> Data
    {
        let (data, response) = try await urlSession.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.noData }
        guard (200..<300).contains(http.statusCode) else
        {
            if let body = String(data: data, encoding: .utf8)
            {
                print("API error \(http.statusCode): \(body)")
            }
            throw APIError.serverError(http.statusCode)
        }
        return data
    }
    
    // MARK: - Generic decoders
    private func getArray<T: Decodable>(_path: String) async throws -> [T]
    {
        let url = try makeURL(path)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, response) = try await urlSession.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.noData }
        
        if http.statusCode == 404
        {
            if let body = String(data: data, encoding: .utf8)
            {
                print("GET \(path) -> 404 (empty): \(body.prefix(200))")
            }
            return []
        }
        
        guard (200..<300).contains(http.statusCode) else
        {
            if let body = String(data: data, encoding: .utf8)
            {
                print("API error \(http.statusCode): \(body)")
            }
            throw APIError.serverError(http.statusCode)
        }
        
        if let str = String(data: data, encoding: .utf8)
        {
            print("GET \(path) response: \(str.prefix(300))")
        }
        return try JSONDecoder().decode(WrappedArray<T>.self, from: data).values
    }
    
    private func getSingle<T: Decodable>(_path: String) async throws -> T
    {
        let url = try makeURL(path)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let data = try await fetchData(request)
        return try JSONDecoder().decode(WrappedSingle<T>.self, from: data).value
    }
    
    private func postSingle<T: Decodable, B: Encodable>(_path: String, body: B) async throws -> T
    {
        let url = try makeURL(path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoded = try JSONEncoder().encode(body)
        request.httpBody = encoded
        if let str = String(data: encoded, encoding: .utf8)
        {
            print("POST \(path) body: \(str.prefix(500))")
        }
        let data = try await fetchData(request)
        if let str = String(data: data, encoding: .utf8)
        {
            print("POST \(path) response: \(str.prefix(500))")
        }
        return try JSONDecoder().decode(WrappedSingle<T>.self, from: data).value
    }
    
    private func putSingle<T: Decodable, B: Encodable>(_path: String, body: B) async throws -> T
    {
        let url = try makeURL(path)
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let encoded = try JSONEncoder().encode(body)
        request.httpBody = encoded
        if let str = String(data: encoded, encoding: .utf8)
        {
            print("PUT \(path) body: \(str.prefix(500))")
        }
        let data = try await fetchData(request)
        if let str = String(data: data, encoding: .utf8)
        {
            print("PUT \(path) response: \(str.prefix(500))")
        }
        return try JSONDecoder().decode(WrappedSingle<T>.self, from: data).value
    }
    
    private func delete(_ path: String) async throws
    {
        let url = try makeURL(path)
        var request = URLRequest(url: url)
        request.httpBody = "DELETE"
        let (_,response) = try await urlSession.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else
        {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? 0)
        }
    }
    
    // MARK: - Users
    
    func getUsersByUsername(_ username: String) async throws -> [User]
    {
        let url = try makeURL("/users", extraParams: ["UserUsername": username])
        var request = URLRequest(url: url)
        request.httpBody = "GET"
        let data = try await fetchData(request)
        if let str = String(data: data, encoding: .utf8)
        {
            print("GET /users?username response: \(str.prefix(200))")
        }
        return (try? JSONDecoder().decode(WrappedSingle<T>.self, from: data).values) ?? []
    }
    
    func getUsers() async throws -> [User]
    {
        try await getArray("/users")
    }
    
    func getUsers(id: String) async throws -> [User]
    {
        try await getSingle("/users/\(id)")
    }
    
    func createUser(_ user: User) async throws -> [User]
    {
        try await postSingle("/users", body: user)
    }
    
    func updateUser(_ user: User) async throws -> [User]
    {
        try await putSingle("/users/\(user.userID.value)", body: user)
    }
    
    func updateUserLocation(user: User, latitude: Double, longitude: Double) async throws -> User
    {
        var updated = user
        updated.userLatitude = latitude
        updated.userLongitude = longitude
        updated.userTimestamp = Date().timeIntervalSince1970
        return try await updateUser(updated)
    }
    
    // MARK: - Events
    
    func getEvents() async throws -> [Event]
    {
        try await getArray("/events")
    }
    
    func getEvent(id: String) async throws -> [Event]
    {
        try await getSingle("/events/\(id)")
    }
    
    func getEvents(forUserID userID: String) async throws -> [Event]
    {
        try await getArray("/events/users/\(userID)")
    }
    
    func createEvent(_ event: Event) async throws -> [Event]
    {
        try await postSingle("/events", body: event)
    }
    
    func updateEvent(_ event: Event) async throws -> [Event]
    {
        try await putSingle("/events/\(event.eventID)", body: event)
    }
    
    func deleteEvent(id: String) async throws
    {
        try await delete("/events/\(id)")
    }
    
    // MARK: - Status
    
    func getStatuses() async throws -> [Status]
    {
        try await getArray("/status")
    }
    
    // MARK: - Players
    func getPlayers() async throws -> [Player]
    {
        try await getArray("/players")
    }
    
    func getPlayer(id: String) async throws -> [Player]
    {
        try await getSingle("/players/\(id)")
    }
    
    func getPlayers(forEventID eventID: String) async throws -> [Player]
    {
        try await getArray("/players/events/\(eventID)")
    }
    
    func createPlayer(_ player: Player) async throws -> [Player]
    {
        try await postSingle("/players", body: player)
    }
    
    func deletePlayer(id: String) async throws
    {
        try await delete("/players/\(id)")
    }
    
}
