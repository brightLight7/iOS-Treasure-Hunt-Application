//
//  EditCacheView.swift
//  Treasure-Hunt_Application
//
//  Created by Reda Ejhani on 10/04/2026.
//

import SwiftUI
import CoreLocation

struct EditCacheView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var locationService: LocationService

    let cache: Cache
    var onUpdated: ((Cache) -> Void)?

    @State private var name: String
    @State private var description: String
    @State private var clue: String
    @State private var points: Double
    @State private var proximityRadius: Double
    @State private var latitude: String
    @State private var longitude: String
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    init(cache: Cache, onUpdated: ((Cache) -> Void)? = nil) {
        self.cache = cache
        self.onUpdated = onUpdated
        _name        = State(initialValue: cache.cacheName)
        _description = State(initialValue: cache.cacheDescription)
        _clue        = State(initialValue: cache.cacheClue)
        _points      = State(initialValue: cache.cachePoints)
        _latitude    = State(initialValue: String(format: "%.6f", cache.cacheLatitude))
        _longitude   = State(initialValue: String(format: "%.6f", cache.cacheLongitude))
        let stored = UserDefaults.standard.double(forKey: "proximity_\(cache.cacheID.value)")
        _proximityRadius = State(initialValue: stored > 0 ? stored : 30.0)
    }
    
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
                            latitude  = String(format: "%.6f", loc.coordinate.latitude)
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
            .navigationTitle("Edit Cache")
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
        guard !name.isEmpty, !clue.isEmpty else {
            errorMessage = "Please fill in all required fields."
            return
        }
        guard let lat = Double(latitude), let lon = Double(longitude) else {
            errorMessage = "Invalid coordinates."
            return
        }
        isLoading = true
        var updated = cache
        updated.cacheName        = name
        updated.cacheDescription = description
        updated.cacheClue        = clue
        updated.cachePoints      = points
        updated.cacheLatitude    = lat
        updated.cacheLongitude   = lon
        do {
            let saved = try await ApiManager.shared.updateCache(updated)
            UserDefaults.standard.set(proximityRadius, forKey: "proximity_\(saved.cacheID.value)")
            onUpdated?(saved)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
