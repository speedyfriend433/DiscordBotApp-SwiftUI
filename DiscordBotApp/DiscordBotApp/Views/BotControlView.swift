//
//  BotControlView.swift
//  DiscordBotApp
//
//  Created by speedy on 2024/12/24.
//

import SwiftUI

struct BotControlView: View {
    @State private var message = ""
    @State private var channelId = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @ObservedObject var settings: BotSettings
    @ObservedObject var storageManager: StorageManager
    private let discordAPI: DiscordAPI
    
    init(settings: BotSettings, storageManager: StorageManager) {
        self.settings = settings
        self.storageManager = storageManager
        self.discordAPI = DiscordAPI(botToken: settings.botToken)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {

                        VStack(alignment: .leading, spacing: 8) {
                            Text("CHANNEL")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                                .fontWeight(.semibold)
                            
                            CustomTextField(placeholder: "Channel ID", text: $channelId)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("MESSAGE")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                                .fontWeight(.semibold)
                            
                            CustomTextField(placeholder: "Type your message...", text: $message)
                                .frame(height: 100)
                        }
                        
                        Button(action: sendMessage) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Send Message")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.accent)
                        .foregroundColor(.white)
                        .cornerRadius(Theme.cornerRadius)
                        .disabled(isLoading)
                        
                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(Theme.error)
                                .padding()
                        }
                        
                        if let success = successMessage {
                            Text(success)
                                .foregroundColor(Theme.success)
                                .padding()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Bot Control")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func sendMessage() {
        guard !message.isEmpty, !channelId.isEmpty else { return }
        
        storageManager.addItem(type: .channelId, value: channelId)
        storageManager.addItem(type: .message, value: message)
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        Task {
            do {
                let _ = try await discordAPI.sendMessage(
                    channelId: channelId,
                    content: message
                )
                message = ""
                successMessage = "Message sent successfully!"
            } catch {
                errorMessage = error.localizedDescription
                print("Error details: \(error)")
            }
            
            isLoading = false
        }
    }
}

    struct MessageHistoryView: View {
        @Environment(\.dismiss) var dismiss
        @ObservedObject var storageManager: StorageManager
        
        var body: some View {
            NavigationView {
                ZStack {
                    Theme.primaryBackground
                        .ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(storageManager.items.filter { $0.type == .message }) { item in
                                MessageHistoryItem(message: item.value, date: item.timestamp)
                            }
                        }
                        .padding()
                    }
                }
                .navigationTitle("Message History")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    struct MessageHistoryItem: View {
        let message: String
        let date: Date
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(message)
                    .foregroundColor(Theme.textPrimary)
                
                Text(date.formatted())
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.secondaryBackground)
            .cornerRadius(Theme.cornerRadius)
        }
    }
    
    struct StatusMessage: View {
        let message: String
        let type: StatusType
        
        enum StatusType {
            case success, error
            
            var color: Color {
                switch self {
                case .success: return Theme.success
                case .error: return Theme.error
                }
            }
            
            var icon: String {
                switch self {
                case .success: return "checkmark.circle.fill"
                case .error: return "exclamationmark.circle.fill"
                }
            }
        }
        
        var body: some View {
            HStack {
                Image(systemName: type.icon)
                Text(message)
            }
            .foregroundColor(type.color)
            .padding()
            .frame(maxWidth: .infinity)
            .background(type.color.opacity(0.1))
            .cornerRadius(Theme.cornerRadius)
        }
    }

#if DEBUG
struct BotControlView_Previews: PreviewProvider {
    static var previews: some View {
        BotControlView(
            settings: BotSettings.default,
            storageManager: StorageManager()
        )
    }
}
#endif
    
