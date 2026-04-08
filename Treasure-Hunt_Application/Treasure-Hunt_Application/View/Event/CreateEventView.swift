//
//  CreateEventView.swift
//  Treasure-Hunt_Application
//
//  Created by Kreshnik Kona on 08/04/2026.
//

import SwiftUI

struct CreateEventView: View {
    
    @EnvironmentObject var eventController: EventController
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: Bool
    
    @State private var name = ""
    @State private var description = ""
    @State private var startDate = Date()
    @State private var finishDate = Date().addingTimeInterval(3600 * 2)
    @State private var isPublic = true
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            Form {
                
                // MARK: Event, Schedule, Visibility
                Section("Event Details") {
                    TextField("Event Name", text: $name)
                        .focused($focusedField)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3)
                        .focused($focusedField)
                }
                
                Section("Schedule") {
                    DatePicker("Starts", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("Finishes", selection: $finishDate, in: startDate..., displayedComponents: [.date, .hourAndMinute])
                }
                
                Section("Visibility") {
                    Toggle("Public Event", isOn: $isPublic)
                    Text(isPublic ? "Anyone can discover and join this event." : "Only players you invite can join.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                if let err = errorMessage {
                    Section {
                        Text(err).foregroundStyle(.red).font(.caption)
                    }
                }
            }
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.immediately)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Create") { Task { await create() } }
                        .fontWeight(.semibold)
                        .disabled(isLoading)
                }
                ToolbarItem(placement: .keyboard) {
                    Button("Done") { focusedField = false }
                }
            }
            .overlay {
                if isLoading { ProgressView() }
            }
        }
    }
    
     // MARK: Create Event
    private func create() async {
        guard name.count >= 8 else {
            errorMessage = "Event name must be at least 8 characters."
            return
        }
        guard finishDate > startDate else {
            errorMessage = "Finish time must be after start time."
            return
        }
        
        isLoading = true
        let result = await eventController.createEvent(
            name: name,
            description: description,
            start: startDate,
            finish: finishDate,
            isPublic: isPublic
        )
        isLoading = false
        if result != nil {
            dismiss()
        } else {
            errorMessage = eventController.errorMessage ?? "Failed to create event."
        }
    }
}
