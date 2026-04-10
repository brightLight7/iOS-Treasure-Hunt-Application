//
//  CacheDetailView.swift
//  Treasure-Hunt_Application
//
//  Created by Reda Ejhani on 07/04/2026.
//

import SwiftUI
import CoreLocation
import UIKit

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
    @State private var pulseAnimation = false
    
    private var cache: Cache { cacheWithStatus.cache }
    private var isFound: Bool { cacheWithStatus.isFound || didLog }
    
    private var proximityThreshold: Double {
        let stored = UserDefaults.standard.double(forKey: "proximity_\(cache.cacheID.value)")
        return stored > 0 ? stored : 30.0
    }
    
    private var distance: Double? { locationService.distance(to: cache) }
    
    private var isNearby: Bool {
        guard let dist = distance else { return false }
        return dist <= proximityThreshold
    }
    
    private var arrowAngle: Double {
        guard let userLoc = locationService.userLocation else { return 0 }
        let bearing = cache.bearing(from: userLoc)
        let heading = locationService.heading?.trueHeading ?? 0
        return bearing - heading
    }
    
    private var backgroundColor: Color {
        isFound || isNearby ? .green : .black
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack(alignment: .topTrailing) {
                    backgroundColor
                        .ignoresSafeArea()
                        .animation(.easeInOut(duration: 0.6), value: isNearby || isFound)
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            finderSection(height: geo.size.height * 0.60)
                            
                            if isNearby || isFound {
                                VStack(spacing: 0) {
                                    detailsSection
                                    Spacer(minLength: 0)
                                }
                                .frame(minHeight: geo.size.height * 0.42)
                                .background(Color(.systemBackground))
                                .clipShape(UnevenRoundedRectangle(
                                    topLeadingRadius: 24, topTrailingRadius: 24))
                            }
                        }
                        .background(
                            VStack(spacing: 0) {
                                Color.clear.frame(height: geo.size.height * 0.60)
                                Color(.systemBackground)
                            }
                        )
                    }
                    
                    Button { dismiss() } label: {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray4).opacity(isNearby || isFound ? 0.5 : 0.3))
                                .frame(width: 34, height: 34)
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(isNearby || isFound ? .white : Color(.systemGray))
                        }
                    }
                    .padding(.top, 12)
                    .padding(.trailing, 16)
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationBarHidden(true)
            .sheet(isPresented: $showCamera) {
                CameraView(imageURL: $capturedImageURL)
            }
            .onChange(of: distance ?? 0) { _, newDist in
                triggerHaptic(for: newDist)
            }
        }
    }
    
    // MARK: - AirTag-style finder section
    
    private func finderSection(height: CGFloat) -> some View {
        VStack(spacing: 0) {
            VStack(spacing: 4) {
                Text("FINDING")
                    .font(.caption2.bold())
                    .foregroundStyle(isNearby || isFound ? .white.opacity(0.75) : .white.opacity(0.5))
                    .tracking(3)
                Text(cache.cacheName)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 12)
            
            Spacer()
            
            if isNearby || isFound {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 220, height: 220)
                        .scaleEffect(pulseAnimation ? 1.18 : 1.0)
                    Circle()
                        .fill(.white.opacity(0.85))
                        .frame(width: 150, height: 150)
                }
                .animation(
                    .easeInOut(duration: 1.1).repeatForever(autoreverses: true),
                    value: pulseAnimation
                )
                .onAppear { pulseAnimation = true }
            } else {
                ZStack {
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(.white.opacity(0.12), lineWidth: 3)
                        .frame(width: 220, height: 220)
                        .rotationEffect(.degrees(144))
                    
                    Image(systemName: "arrow.up")
                        .font(.system(size: 110, weight: .bold))
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(arrowAngle))
                        .animation(.easeInOut(duration: 0.35), value: arrowAngle)
                }
                .frame(maxWidth: .infinity)
            }
            
            Spacer()
            
            VStack(spacing: 6) {
                if let dist = distance {
                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text("\(Int(dist))")
                            .font(.system(size: 60, weight: .bold))
                            .foregroundStyle(.white)
                        Text("m")
                            .font(.title)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    Text(isNearby || isFound ? "nearby" : directionText)
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.75))
                } else {
                    Text("Locating…")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.6))
                }

                // Points + status badge
                HStack(spacing: 10) {
                    Text("\(Int(cache.cachePoints)) pts")
                        .font(.subheadline.bold())
                        .foregroundStyle(isNearby || isFound ? .white : .green)
                    StatusBadge(isFound: isFound, isNearby: isNearby)
                }
                .padding(.top, 4)

                // Proximity hint when far
                if !isNearby && !isFound {
                    Text("Get within \(Int(proximityThreshold)) m to unlock")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.top, 2)
                }
            }
            .padding(.bottom, 28)
        }
        .frame(height: height)
    }
    
    // MARK: - Details section (slides up when nearby)
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text(cache.cacheDescription)
                .foregroundStyle(.secondary)
                .font(.subheadline)
                .padding(.top, 20)

            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Button {
                    withAnimation { showClue.toggle() }
                } label: {
                    Label(showClue ? "Hide Clue" : "Reveal Clue",
                          systemImage: showClue ? "eye.slash" : "eye")
                        .foregroundStyle(.green)
                }
                if showClue {
                    Text(cache.cacheClue)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .transition(.opacity)
                }
            }
            
            if cacheWithStatus.isFound, let find = cacheWithStatus.find, let date = find.findDate {
                HStack {
                    Image(systemName: "checkmark.seal.fill").foregroundStyle(.green)
                    Text("Found \(date, style: .relative) ago")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            
            if !isFound {
                if let urlString = capturedImageURL,
                   let url = URL(string: urlString),
                   let uiImage = UIImage(contentsOfFile: url.path) {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                            Text("Photo captured!")
                                .foregroundStyle(.green).font(.subheadline)
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

                Button { showCamera = true } label: {
                    Label(capturedImageURL == nil ? "Take Photo Evidence" : "Retake Photo",
                          systemImage: "camera")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button { Task { await logTheFind() } } label: {
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
            
            if didLog {
                HStack {
                    Image(systemName: "checkmark.seal.fill").foregroundStyle(.green)
                    Text("Cache found! Well done!")
                        .font(.subheadline.bold()).foregroundStyle(.green)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.green.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }
    
    // MARK: - Helpers
    
    private var directionText: String {
        let angle = (arrowAngle.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        switch angle {
        case 337.5...360, 0..<22.5:  return "ahead"
        case 22.5..<112.5:           return "to your right"
        case 112.5..<157.5:          return "behind and right"
        case 157.5..<202.5:          return "behind you"
        case 202.5..<247.5:          return "behind and left"
        default:                      return "to your left"
        }
    }

    private func triggerHaptic(for dist: Double) {
        guard dist > 0 else { return }
        let style: UIImpactFeedbackGenerator.FeedbackStyle =
            dist < 10 ? .heavy : dist < 30 ? .medium : .light
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    private func logTheFind() async {
        isLogging = true
        let imageURL = capturedImageURL ?? "https://placehold.co/300x300/png"
        let success = await mapController.logFind(for: cache, imageURL: imageURL)
        isLogging = false
        if success { didLog = true }
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
            .background(color.opacity(0.2))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private var label: String {
        isFound ? "Found" : (isNearby ? "Nearby!" : "Hidden")
    }
    private var color: Color {
        isFound ? .white.opacity(0.6) : (isNearby ? .white : .green)
    }
}

