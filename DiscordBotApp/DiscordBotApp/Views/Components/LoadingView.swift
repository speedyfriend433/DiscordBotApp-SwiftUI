//
//  LoadingView.swift
//  DiscordBotApp
//
//  Created by speedy on 2024/12/24.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .scaleEffect(1.5)
            .padding()
    }
}
