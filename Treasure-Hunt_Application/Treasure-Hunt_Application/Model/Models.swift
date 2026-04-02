//
//  Models.swift
//  
//
//  Created by Abdullah Sajid on 02/04/2026.
//

import Foundation

// MARK: - FlexibleID

struct FlexibleID: Codable, Hashable, CustomStringConvertible{
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
