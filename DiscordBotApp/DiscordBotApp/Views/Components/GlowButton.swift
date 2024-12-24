//
//  GlowButton.swift
//  DiscordBotApp
//
//  Created by speedy on 2024/12/24.
//

import SwiftUI

struct GlowButton: View {
    let title: String
    let action: () -> Void
    let isLoading: Bool
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Theme.accent)
            .cornerRadius(Theme.cornerRadius)
            .shadow(color: Theme.accent.opacity(Theme.glowOpacity), radius: Theme.glowRadius)
        }
        .disabled(isLoading)
    }
}
