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
