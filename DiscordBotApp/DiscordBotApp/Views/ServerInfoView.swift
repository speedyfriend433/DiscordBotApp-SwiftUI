//
//  ServerInfoView.swift
//  DiscordBotApp
//
//  Created by speedy on 2024/12/24.
//

import SwiftUI

struct ServerInfoView: View {
    @ObservedObject var settings: BotSettings
    private let discordAPI: DiscordAPI
    @State private var serverInfo: ServerInfo?
    @State private var isLoading = false
    @State private var error: Error?
    @State private var showError = false
    @State private var serverId: String = ""
    @ObservedObject var storageManager: StorageManager
    
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
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Theme.accent))
                } else if let serverInfo = serverInfo {
                    ScrollView {
                        VStack(spacing: 20) {

                            ServerHeaderView(serverInfo: serverInfo)
                            
                            ChannelsSectionView(channels: serverInfo.channels)
                            
                            RolesSectionView(roles: serverInfo.roles)
                        }
                        .padding()
                    }
                } else {
                    VStack(spacing: 20) {
                        CustomTextField(
                            placeholder: "Enter Server ID",
                            text: $serverId
                        )
                        .padding(.horizontal)
                        
                        Button(action: fetchServerInfo) {
                            Text("Load Server Info")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.accent)
                                .foregroundColor(.white)
                                .cornerRadius(Theme.cornerRadius)
                        }
                        .padding(.horizontal)
                        
                        if settings.botToken.isEmpty {
                            Text("Bot token not set")
                                .foregroundColor(Theme.error)
                                .padding()
                        }
                    }
                }
            }
            .navigationTitle("Server Info")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(error?.localizedDescription ?? "Unknown error occurred")
            }
        }
    }
    
    private func fetchServerInfo() {
        guard !serverId.isEmpty else { return }
        guard !settings.botToken.isEmpty else {
            error = DiscordError.unauthorized
            showError = true
            return
        }
        
        storageManager.addItem(type: .serverId, value: serverId)
        
        discordAPI.updateToken(settings.botToken)
        isLoading = true
        
        Task {
            do {
                serverInfo = try await discordAPI.getServerInfo(serverId: serverId)

                if let name = serverInfo?.name {
                    storageManager.updateLabel(for: serverId, type: .serverId, label: name)
                }
            } catch {
                self.error = error
                self.showError = true
            }
            isLoading = false
        }
    }
    
    struct ServerHeaderView: View {
        let serverInfo: ServerInfo
        
        var body: some View {
            VStack(spacing: 12) {
                if let icon = serverInfo.icon {
                    AsyncImage(url: URL(string: "https://cdn.discordapp.com/icons/\(serverInfo.id)/\(icon).png")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    } placeholder: {
                        Circle()
                            .fill(Theme.secondaryBackground)
                            .frame(width: 80, height: 80)
                    }
                }
                
                Text(serverInfo.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
                
                if let description = serverInfo.description {
                    Text(description)
                        .foregroundColor(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                HStack(spacing: 20) {
                    if let memberCount = serverInfo.memberCount {
                        StatView(title: "Members", value: "\(memberCount)")
                    }
                    if let presenceCount = serverInfo.presenceCount {
                        StatView(title: "Online", value: "\(presenceCount)")
                    }
                }
            }
            .padding()
            .background(Theme.secondaryBackground)
            .cornerRadius(Theme.cornerRadius)
        }
    }
    
    struct ChannelsSectionView: View {
        let channels: [ChannelInfo]?
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("CHANNELS")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.textSecondary)
                
                if let channels = channels {
                    ForEach(channels.sorted(by: { ($0.position ?? 0) < ($1.position ?? 0) })) { channel in
                        HStack(spacing: 12) {
                            Image(systemName: channel.channelType.icon)
                                .foregroundColor(Theme.accent)
                            
                            Text(channel.name)
                                .foregroundColor(Theme.textPrimary)
                            
                            Spacer()
                            
                            Text(channel.channelType.name)
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        }
                        .padding()
                        .background(Theme.secondaryBackground)
                        .cornerRadius(Theme.cornerRadius)
                    }
                } else {
                    Text("No channels available")
                        .foregroundColor(Theme.textSecondary)
                }
            }
        }
    }
    
    struct RolesSectionView: View {
        let roles: [RoleInfo]?
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text("ROLES")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.textSecondary)
                
                if let roles = roles {
                    ForEach(roles.sorted(by: { $0.position > $1.position })) { role in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color(hex: role.hexColor))
                                .frame(width: 12, height: 12)
                            
                            Text(role.name)
                                .foregroundColor(Theme.textPrimary)
                            
                            Spacer()
                            
                            Text("Level \(role.position)")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                        }
                        .padding()
                        .background(Theme.secondaryBackground)
                        .cornerRadius(Theme.cornerRadius)
                    }
                } else {
                    Text("No roles available")
                        .foregroundColor(Theme.textSecondary)
                }
            }
        }
    }
    
    struct StatView: View {
        let title: String
        let value: String
        
        var body: some View {
            VStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.textPrimary)
            }
        }
    }
    
#if DEBUG
    struct ServerInfoView_Previews: PreviewProvider {
        static var previews: some View {
            ServerInfoView(
                settings: BotSettings(
                    botToken: "preview-token",
                    defaultChannelId: nil,
                    commandPrefix: "!"
                ),
                storageManager: StorageManager()
            )
        }
    }
#endif
}
