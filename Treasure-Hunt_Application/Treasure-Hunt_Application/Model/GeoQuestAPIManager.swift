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
}
