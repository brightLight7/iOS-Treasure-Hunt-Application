//
//  EventListView.swift
//  Treasure-Hunt_Application
//
//  Created by Kreshnik Kona on 08/04/2026.
//

import SwiftUI

struct EventListView: View {
    @EnvironmentObject var eventController: EventController
    @EnvironmentObject var authController: AuthController
    @EnvironmentObject var locationService: LocationService
    @State private var showCreateEvent = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            
            // Tab Picker
            VStack(spacing: 0) {
                Picker("", selection: $selectedTab) {
                    Text("All Events").tag(0)
                    Text("My Events").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Loading
                if eventController.isLoading {
                    Spacer()
                    ProgressView("Loading events…")
                    Spacer()
                } else {
                    
                    // Event List
                    let displayEvents = selectedTab == 0 ?
                    eventController.events : eventController.myEvents
                    if displayEvents.isEmpty {
                        ContentUnavailableView(
                            selectedTab == 0 ? "No events yet" : "You haven't created any events", systemImage: "flag.slash", description: Text(selectedTab == 1 ? "Tap + to create one" : "")
                        )
                    } else {
                        List(displayEvents) { event in
                            NavigationLink {
                                EventDetailView(event: event)
                                    .environmentObject(eventController)
                                    .environmentObject(locationService)
                            } label: {
                                EventRowView(event: event, statusName:
                                                eventController.statusName(forID: event.eventStatusID))
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            
            // Navigation/Toolbar
            .navigationTitle("Events")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreateEvent = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateEvent) {
                CreateEventView()
                    .environmentObject(eventController)
            }
            .task {
                await eventController.loadAll()
            }
            .refreshable {
                await eventController.loadAll()
            }
        }
    }
}

// MARK: Event Row

struct EventRowView: View {
    let event: Event
    let statusName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(event.eventName)
                    .font(.headline)
                Spacer()
                Text(statusName)
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.green.opacity(0.15))
                    .foregroundStyle(.green)
                    .clipShape(Capsule())
            }
            Text(event.eventDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            if let start = event.startDate {
                Label(start.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            HStack {
                Image(systemName: event.eventIsPublic ? "globe" : "lock")
                    .font(.caption)
                Text(event.eventIsPublic ? "Public" : "Private")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
