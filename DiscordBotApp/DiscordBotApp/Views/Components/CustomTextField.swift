//
//  CustomTextField.swift
//  DiscordBotApp
//
//  Created by speedy on 2024/12/24.
//

import SwiftUI

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .textFieldStyle(.plain)
        .padding()
        .background(Theme.inputBackground)
        .cornerRadius(Theme.cornerRadius)
        .foregroundColor(Theme.textPrimary)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(Theme.accent.opacity(0.3), lineWidth: 1)
        )
    }
}
