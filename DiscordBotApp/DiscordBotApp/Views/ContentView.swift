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
    
    var body: some View {
        TabView {
            BotControlView(settings: settings, storageManager: storageManager)
                .tabItem {
                    Label("Bot Control", systemImage: "message")
                }
            
            StorageView(storageManager: storageManager)  // Pass storageManager here
                .tabItem {
                    Label("Storage", systemImage: "archivebox")
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

                    .background(Theme.primaryBackground)
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

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

// MARK: - TabView Padding Reminder

/* .background(Theme.primaryBackground)
 .onAppear {
     // Set the tab bar background color
     let appearance = UITabBarAppearance()
     appearance.configureWithOpaqueBackground()
     appearance.backgroundColor = UIColor(Theme.primaryBackground)
     
     UITabBar.appearance().standardAppearance = appearance
     if #available(iOS 15.0, *) {
         UITabBar.appearance().scrollEdgeAppearance = appearance
     }
 } */
