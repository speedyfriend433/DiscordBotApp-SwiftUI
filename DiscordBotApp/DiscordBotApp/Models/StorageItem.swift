//
//  StorageItem.swift
//  DiscordBotApp
//
//  Created by speedy on 2024/12/24.
//

import Foundation

struct StorageItem: Identifiable, Codable {
    let id: UUID
    let type: ItemType
    let value: String
    let timestamp: Date
    var label: String?
    var memo: String?
    
    enum ItemType: String, Codable, Hashable {
        case token
        case channelId
        case message
        case serverId
        
        var icon: String {
            switch self {
            case .token: return "key.fill"
            case .channelId: return "number"
            case .message: return "message.fill"
            case .serverId: return "server.rack"
            }
        }
        
        var title: String {
            switch self {
            case .token: return "Bot Tokens"
            case .channelId: return "Channel IDs"
            case .message: return "Messages"
            case .serverId: return "Server IDs"
            }
        }
    }
}
