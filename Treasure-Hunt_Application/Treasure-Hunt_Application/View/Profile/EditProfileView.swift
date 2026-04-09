//
//  EditProfileView.swift
//  Treasure-Hunt_Application
//
//  Created by Kreshnik Kona on 09/04/2026.
//

import SwiftUI

struct EditProfileView: View {
    @EnvironmentObject var authController: AuthController
    @Environment(\.dismiss) var dismiss
    
    @State private var firstname: String = ""
    @State private var lastname: String = ""
    @State private var phone: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Personal Info") {
                    GQTextField(title: "First Name", text: $firstname, icon: "person")
                    GQTextField(title: "Last Name", text: $lastname, icon: "person")
                    GQTextField(title: "Phone", text: $phone, icon: "phone")
                }
                
                if let err = authController.errorMessage {
                    Section {
                        Text(err).foregroundStyle(.red).font(.caption)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        Task {
                            guard var user = authController.currentUser else { return }
                            user.userFirstname = firstname
                            user.userLastname = lastname
                            user.userPhone = phone
                            await authController.updateCurrentUser(user)
                            if authController.errorMessage == nil { dismiss() }
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(authController.isLoading)
                }
            }
            .onAppear {
                if let user = authController.currentUser {
                    firstname = user.userFirstname
                    lastname = user.userLastname
                    phone = user.userPhone
                }
            }
        }
    }
}
