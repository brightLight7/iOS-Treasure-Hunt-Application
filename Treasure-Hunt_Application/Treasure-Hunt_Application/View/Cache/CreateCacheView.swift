//
//  CreateCacheView.swift
//  Treasure-Hunt_Application
//
//  Created by Reda Ejhani on 07/04/2026.
//

import SwiftUI
import MapKit
import CoreLocation

struct CreateCacheView: View {
    @Environment(\.dismiss) var dismiss
    let event: Event
    var onCreated: ((Cache) -> Void)?
    
    @State private var name = ""
    @State private var description = ""
    @State private var clue = ""
    @State private var points = 10.0
    @State private var proximityRadius = 30.0
    @State private var latitude = ""
    @State private var longitude = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    @EnvironmentObject var locationService: LocationService
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Cache Details") {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3)
                    TextField("Clue or Riddle", text: $clue, axis: .vertical)
                        .lineLimit(3)
                }
                
                Section("Points Value") {
                    Stepper("\(Int(points)) points", value: $points, in: 1...100, step: 5)
                }
                
                Section {
                    Stepper("Unlock radius: \(Int(proximityRadius)) m",
                            value: $proximityRadius, in: 5...200, step: 5)
                    Text("Players must be within \(Int(proximityRadius)) metres to unlock this cache.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Proximity")
                }
                
                Section("GPS Location") {
                    TextField("Latitude", text: $latitude)
                        .keyboardType(.decimalPad)
                    TextField("Longitude", text: $longitude)
                        .keyboardType(.decimalPad)
                    
                    Button("Use My Current Location") {
                        if let loc = locationService.userLocation {
                            latitude = String(format: "%.6f", loc.coordinate.latitude)
                            longitude = String(format: "%.6f", loc.coordinate.longitude)
                        }
                    }
                    .foregroundStyle(.green)
                }
                
                if let err = errorMessage {
                    Section {
                        Text(err).foregroundStyle(.red).font(.caption)
                    }
                }
            }
            .navigationTitle("New Cache")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { Task { await save() } }
                        .disabled(isLoading)
                        .fontWeight(.semibold)
                }
            }
            .overlay {
                if isLoading { ProgressView() }
            }
        }
    }
    
    private func save() async {
        guard !name.isEmpty else {
            errorMessage = "Please fill in all required fields."
            return
        }
        guard let lat = Double(latitude), let lon = Double(longitude) else {
            errorMessage = "Invalid coordinates."
            return
        }
        isLoading = true
        let cache = Cache(
            cacheID: FlexibleID("0"),
            cacheName: name,
            cacheDescription: description,
            cacheEventID: event.eventID,
            cacheImageURL: nil,
            cacheClue: clue,
            cachePoints: points,
            cacheLatitude: lat,
            cacheLongitude: lon,
            cacheEvent: nil
            )
        do {
            let created = try await ApiManager.shared.createCache(cache)
            UserDefaults.standard.set(proximityRadius, forKey: "proximity_\(created.cacheID.value)")
            onCreated?(created)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
