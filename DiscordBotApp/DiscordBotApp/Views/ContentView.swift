//
//  ContentView.swift
//  DiscordBotApp
//
//  Created by speedy on 2024/12/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var settings = BotSettings.default
    @StateObject private var storageManager = StorageManager()
    @StateObject private var commandManager = CommandManager()
    @StateObject private var autoResponseManager = AutoResponseManager()
    
    var body: some View {
        TabView {
            BotControlView(
                settings: settings,
                storageManager: storageManager,
                autoResponseManager: autoResponseManager
            )
            .tabItem {
                Label("Bot Control", systemImage: "message")
            }
            
            StorageView(storageManager: storageManager)
                .tabItem {
                    Label("Storage", systemImage: "archivebox")
                }
            
            CommandsView(commandManager: commandManager)
                .tabItem {
                    Label("Commands", systemImage: "terminal")
                }
            
            AutoResponseView(autoResponseManager: autoResponseManager)
                .tabItem {
                    Label("Auto Reply", systemImage: "bubble.left.and.bubble.right")
                }
            
            ServerInfoView(settings: settings, storageManager: storageManager)
                .tabItem {
                    Label("Server", systemImage: "server.rack")
                }
            
            SettingsView(settings: settings, storageManager: storageManager)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .onAppear {

            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Theme.primaryBackground)
            
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: - TabView Padding Reminder

/* .background(Theme.primaryBackground)
 .onAppear {

     let appearance = UITabBarAppearance()
     appearance.configureWithOpaqueBackground()
     appearance.backgroundColor = UIColor(Theme.primaryBackground)
     
     UITabBar.appearance().standardAppearance = appearance
     if #available(iOS 15.0, *) {
         UITabBar.appearance().scrollEdgeAppearance = appearance
     }
 } */
