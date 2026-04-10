//
//  EditEventView.swift
//  Treasure-Hunt_Application
//
//  Created by Kreshnik Kona on 10/04/2026.
//

import SwiftUI

struct EditEventView: View {
    @EnvironmentObject var eventController: EventController
    @Environment(\.dismiss) var dismiss
    
    let event: Event
    var onUpdated: ((Event) -> Void)?
    
    @State private var name: String
    @State private var description: String
    @State private var startDate: Date
    @State private var finishDate: Date
    @State private var isPublic: Bool
    @State private var isLoading = false
    @State private var errorMessage: String?
    @FocusState private var focusedField: Bool
    
    init(event: Event, onUpdated: ((Event) -> Void)? = nil) {
        self.event = event
        self.onUpdated = onUpdated
        _name = State(initialValue: event.eventName)
        _description = State(initialValue: event.eventDescription)
        _startDate = State(initialValue: event.startDate ?? Date())
        _finishDate = State(initialValue: event.finishDate ?? Date().addingTimeInterval(3600 * 2))
        _isPublic = State(initialValue: event.eventIsPublic)
    }
    
    var body: some View {
        NavigationStack {
            Form {
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
            .navigationTitle("Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.immediately)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { Task { await save() } }
                        .fontWeight(.semibold)
                        .disabled(isLoading || name.count < 8)
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
    
    // MARK: Save
    
    private func save() async {
        guard name.count >= 8 else {
            errorMessage = "Event name must be at least 8 characters."
            return
        }
        guard finishDate > startDate else {
            errorMessage = "Finish time must be after start time."
            return
        }
        isLoading = true
        let result = await eventController.updateEvent(
            event,
            name: name,
            description: description,
            start: startDate,
            finish: finishDate,
            isPublic: isPublic
        )
        isLoading = false
        if let updated = result {
            onUpdated?(updated)
            dismiss()
        } else {
            errorMessage = eventController.errorMessage ?? "Failed to save changes."
        }
    }
}
