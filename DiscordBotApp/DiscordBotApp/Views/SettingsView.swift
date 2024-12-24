//
//  SettingsView.swift
//  DiscordBotApp
//
//  Created by speedy on 2024/12/24.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: BotSettings
    @ObservedObject var storageManager: StorageManager
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 20) {
                            SectionHeader(title: "BOT CONFIGURATION")
                            
                            VStack(spacing: 16) {
                                CustomTextField(
                                    placeholder: "Bot Token",
                                    text: Binding(
                                        get: { self.settings.botToken },
                                        set: {
                                            self.settings.botToken = $0
                                            self.storageManager.addItem(type: .token, value: $0)
                                        }
                                    ),
                                    isSecure: true
                                )
                                
                                CustomTextField(
                                    placeholder: "Default Channel ID",
                                    text: Binding(
                                        get: { self.settings.defaultChannelId ?? "" },
                                        set: {
                                            self.settings.defaultChannelId = $0.isEmpty ? nil : $0
                                            if !$0.isEmpty {
                                                self.storageManager.addItem(type: .channelId, value: $0)
                                            }
                                        }
                                    )
                                )
                                
                                CustomTextField(
                                    placeholder: "Command Prefix",
                                    text: Binding(
                                        get: { self.settings.commandPrefix },
                                        set: { self.settings.commandPrefix = $0 }
                                    )
                                )
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            SectionHeader(title: "ABOUT")
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Discord Bot Controller")
                                    .font(.headline)
                                    .foregroundColor(Theme.textPrimary)
                                
                                Text("Version 1.0")
                                    .font(.subheadline)
                                    .foregroundColor(Theme.textSecondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Theme.secondaryBackground)
                            .cornerRadius(Theme.cornerRadius)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(
            settings: BotSettings.default,
            storageManager: StorageManager()
        )
    }
}
#endif
