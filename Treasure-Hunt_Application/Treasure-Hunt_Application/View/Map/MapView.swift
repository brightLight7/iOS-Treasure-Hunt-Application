//
//  MapView.swift
//  Treasure-Hunt_Application
//
//  Created by Reda Ejhani on 07/04/2026.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var mapController: MapController
    @EnvironmentObject var locationService: LocationService
    @State private var selectedCache: CacheWithStatus?
    @State private var position: MapCameraPosition = .automatic
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(position: $position) {
                UserAnnotation()
                ForEach(mapController.caches) { item in
                    Annotation(item.cache.cacheName, coordinate: <#T##CLLocationCoordinate2D#>(
                        latitude: item.cache.cacheLatitude,
                        longitude: item.cache.cacheLongitude
                    )) {
                        CacheAnnotationView(
                            cacheWithStatus: item,
                            isNearby: mapController.canUnlock(cache: item.cache)
                            )
                        .onTapGesture { selectedCache = item }
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            .mapControls {
                MapCompass()
                MapScaleView()
            }
            
            VStack(spacing: 12) {
                Button {
                    if let loc = locationService.userLocation {
                        withAnimation {
                            position = .camera(MapCamera(
                                centerCoordinate: loc.coordinate
                                distance: 1000
                                ))
                        }
                    } label: {
                        Image(systemName: "location.fill")
                            .padding(14)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    
                    Button {
                        Task { await mapController.loadGlobalCaches() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .padding(14)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                }
                .padding()
            }
            .navigationtitle("Explore")
            .sheet(item: $selectedCache) { item in
                CacheDetailView(cacheWithStatus: item)
                    .environmentObject(mapController)
                    .environmentObject(locationService)
        }
        .task {
                mapController.setup(locationService: locationService)
                locationService.requestPermission()
                await mapController.loadGlobalCaches()
        }
        .overlay {
            if mapController.isLoading {
                ProgressView("Loading caches...")
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

