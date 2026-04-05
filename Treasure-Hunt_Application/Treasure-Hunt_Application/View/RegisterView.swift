//
//  RegisterView.swift
//  Treasure-Hunt_Application
//
//  Created by Abdullah Sajid on 04/04/2026.
//

import SwiftUI

struct RegisterView: View
{
    @EnvironmentObject var authController: AuthController
    @Environment(\.dismiss) var dismiss
    
    @State private var firstname = ""
    @State private var lastname = ""
    @State private var username = ""
    @State private var countryCode = "44"
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View
    {
        ScrollView
        {
            VStack(spacing: 20)
            {
                Text("Create Account")
                    .font(.title2.bold())
                    .padding(.top)
                
                VStack(spacing: 14)
                {
                    GQTextField(title: "First Name", text: $firstname, icon: "person")
                    GQTextField(title: "Last Name", text: lastname, icon: "person")
                    GQTextField(title: "Username", text: $username, icon: "at")
                    
                    HStack(spacing: 8)
                    {
                        HStack(spacing: 4)
                        {
                            Image(systemName: "phone")
                                .foregroundStyle(.primary)
                            TextField("44". text: $countryCode)
                                .keyboardType(.numberPad)
                                .frame(width: 36)
                        }
                        .padding(14)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    GQTextField(title: "Password", text: $password, icon: "lock", isSecure: true)
                }
                if let err = authController.errorMessage
                {
                    Text(err)
                        .foregroundStyle(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                Button
                {
                    guard password == confirmPassword else
                    {
                        authController.errorMessage = "Passwords do not match."
                        return
                    }
                    let fullPhone = "+\(countryCode) \(phoneNumber)"
                    Task
                    {
                        await authController.register(firstname: firstname, lastname: lastname, username: username, phone: fullPhone, password: password)
                    }
                    if authController.isLoggedIn { dismiss() }
                }
            label:
                {
                    Group
                    {
                        if authController.isLoading
                        {
                            ProgressView().tint(.white)
                        }
                        else
                        {
                            Text("Create Account").fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.green)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(authController.isLoading)
            }
            .padding()
        }
        .navigationTitle("Register")
        .navigationBarTitleDisplayMode(.incline)
    }
}
