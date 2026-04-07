//
//  CacheDetailView.swift
//  Treasure-Hunt_Application
//
//  Created by Reda Ejhani on 07/04/2026.
//

import SwiftUI
import CoreLocation

struct CacheDetailView: View {
    @EnvironmentObject var mapController: MapController
    @EnvironmentObject var locationService: LocationService
    @Environment(\.dismiss) var dismiss
    
    let cacheWithStatus: CacheWithStatus
    
    @State private var showClue = false
    @State private var showCamera = false
    @State private var capturedImageURL: String?
    @State private var isLogging = false
    @State private var didLog = false
    
    private var cache: Cache { cacheWithStatus.cache }
    private var isNearby: Bool { mapController.canUnlock(cache: cache) }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(cache.cacheName)
                                .font(.title2.bold())
                            Text("\(Int(cache.cachePoints)) pts")
                                .font(.subheadline)
                                .foregroundStyle(.green)
                        }
                        Spacer()
                        StatusBadge(isFound: cacheWithStatus.isFound || didLog, isNearby: isNearby)
                    }
                    
                    Text(cache.cacheDescription)
                        .foregroundStyle(.secondary)
                    
                    Divider()
                    
                    if let dist = locationService.distance(to: cache) {
                        HStack {
                            Image(systemName: "location.circle")
                                .foregroundStyle(.blue)
                            Text(String(format: "%.0f m away", dist))
                                .font(.subheadline)
                        }
                    }
                    
                    if let userLoc = locationService.userLocation {
                        let bearing = cache.bearing(from: userLoc)
                        let headingOffset = locationService.heading?.trueHeading ?? 0
                        HStack {
                            CompassArrow(bearingDegress: bearing - headingOffset)
                            Text("Head this way")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if !isNearby && !cacheWithStatus.isFound && !didLog {
                        Label("Get within 30 m to unlock", systemImage: "figure.walk")
                            .font(.footnote)
                            .foregroundStyle(.orange)
                            .padding(10)
                            .background(Color.orange.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    if !isNearby || cacheWithStatus.isFound || didLog {
                        VStack(alignment: .leading, spacing: 8) {
                            Button {
                                withAnimation { showClue.toggle() }
                            } label: {
                                Label(showClue ? "Hide Clue" : "Reveal Clue",
                                      systemImage: showClue ? "eye.slash" : "eye")
                            }
                            if showClue {
                                Text(cache.cacheClue)
                                    .padding()
                                    .background(Color(.secondarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .transition(.opacity)
                            }
                        }
                    }
                    
                    if !cacheWithStatus.isFound && !didLog && isNearby {
                        VStack(spacing: 12) {
                            if let urlString = capturedImageURL,
                               let url = URL(string: urlString),
                               let data = try? Data(contentsOf: url),
                               let uiImage = UIImage(data: data) {
                                VStack(spacing: 8) {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                        Text("Photo captured!")
                                            .font(.subheadline)
                                            .foregroundStyle(.green)
                                        Spacer()
                                    }
                                    
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 200)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            
                            Button {
                                showCamera = true
                            } label: {
                                Label(capturedImageURL == nil ? "Take Photo Evidence" : "Retake Photo", systemImage: "camera")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.secondarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            
                            Button {
                                Task { await logTheFind() }
                            } label: {
                                Group {
                                    if isLogging {
                                        ProgressView().tint(.white)
                                    } else {
                                        Label("Log Find", systemImage: "checkmark.circle.fill")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.green)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                            .disabled(isLogging)
                        }
                    }
                    
                    if didLog {
                        HStack {
                            Image(systemName: "checkmark.seal.fill").foregroundStyle(.green)
                            Text("Cache found! Well done!")
                                .font(.subheadline.bold())
                                .foregroundStyle(.green)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.green.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    if cacheWithStatus.isFound, let find = cacheWithStatus.find {
                        HStack {
                            Image(systemName: "checkmark.seal.fill").foregroundStyle(.green)
                            if let date = find.findDate {
                                Text("Found \(date, style: .relative) ago")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding()
                
            }
            .navigationTitle("Cache Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolBarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showCamera) {
                CameraView(imageURL: $capturedImageURL)
            }
        }
    }
    
    private func logTheFind() async {
        isLogging = true
        
        let imageURL = capturedImageURL ?? "https://placehold.co/300x300/png"
        let success = await mapController.logFind(for: cache, imageURL: imageURL)
        
        isLogging = false
        if sucess {
            didLog = true
        }
    }
}

// MARK: - Status badge

struct StatusBadge: View {
    let isFound: Bool
    let isNearby: Bool
    
    var body: some View {
        Text(label)
            .font(.caption.bold())
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }
    
    private var label: String {
        isFound ? "Found" : (isNearby ? "Nearby!" : "Hidden")
    }
    
    private var color: Color {
        isFound ? .gray : (isNearby ? .orange : .green)
    }
}

