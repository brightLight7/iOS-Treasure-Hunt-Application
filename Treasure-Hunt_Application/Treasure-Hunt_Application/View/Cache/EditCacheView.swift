//
//  EditCacheView.swift
//  Treasure-Hunt_Application
//
//  Created by Reda Ejhani on 10/04/2026.
//

import SwiftUI
import MapKit
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
    @State private var pinCoordinate: CLLocationCoordinate2D
    @State private var cameraPosition: MapCameraPosition
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    init(cache: Cache, onUpdated: ((Cache) -> Void)? = nil) {
        self.cache = cache
        self.onUpdated = onUpdated
        _name        = State(initialValue: cache.cacheName)
        _description = State(initialValue: cache.cacheDescription)
        _clue        = State(initialValue: cache.cacheClue)
        _points      = State(initialValue: cache.cachePoints)
        let coord = CLLocationCoordinate2D(latitude: cache.cacheLatitude, longitude: cache.cacheLongitude)
        _pinCoordinate = State(initialValue: coord)
        _cameraPosition = State(initialValue: .region(MKCoordinateRegion(
            center: coord,
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        )))
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

                Section("Cache Location") {
                    MapReader { proxy in
                        Map(position: $cameraPosition) {
                            Annotation("", coordinate: pinCoordinate) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(.red)
                            }
                        }
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .onTapGesture { position in
                            if let coord = proxy.convert(position, from: .local) {
                                pinCoordinate = coord
                            }
                        }
                    }
                    Button("Use My Current Location") {
                        if let loc = locationService.userLocation {
                            pinCoordinate = loc.coordinate
                            cameraPosition = .region(MKCoordinateRegion(
                                center: loc.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                            ))
                        }
                    }
                    .foregroundStyle(.green)
                    Text("Swipe to pan · Pinch to zoom · Tap to place pin")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
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
        isLoading = true
        var updated = cache
        updated.cacheName        = name
        updated.cacheDescription = description
        updated.cacheClue        = clue
        updated.cachePoints      = points
        updated.cacheLatitude    = pinCoordinate.latitude
        updated.cacheLongitude   = pinCoordinate.longitude
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
