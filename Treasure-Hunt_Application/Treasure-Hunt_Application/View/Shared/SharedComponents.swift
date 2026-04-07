//
//  SharedComponents.swift
//  Treasure-Hunt_Application
//
//  Created by Reda Ejhani on 07/04/2026.
//

import SwiftUI

// MARK: - GQTextField

struct GQTextField: View {
    
    let title: String
    @Binding var text: String
    let icon: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            
            if isSecure {
                SecureField(title, text: $text)
            } else {
                TextField(title, text: $text)
                    .keyboardType(keyboardType)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

