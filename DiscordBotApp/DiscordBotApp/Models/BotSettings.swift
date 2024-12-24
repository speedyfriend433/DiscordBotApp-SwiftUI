//
//  BotSettings.swift
//  DiscordBotApp
//
//  Created by speedy on 2024/12/24.
//

import Foundation

class BotSettings: ObservableObject {
    @Published var botToken: String
    @Published var defaultChannelId: String?
    @Published var commandPrefix: String
    
    init(botToken: String, defaultChannelId: String? = nil, commandPrefix: String = "!") {
        self.botToken = botToken
        self.defaultChannelId = defaultChannelId
        self.commandPrefix = commandPrefix
    }
    
    static let `default` = BotSettings(botToken: "", commandPrefix: "!")
}
