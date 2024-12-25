//
//  ServerModels.swift
//  DiscordBotApp
//
//  Created by speedy on 2024/12/24.
//

import Foundation

struct ServerInfo: Codable, Identifiable {
    let id: String
    let name: String
    let icon: String?
    let description: String?
    let memberCount: Int?
    let presenceCount: Int?
    let channels: [ChannelInfo]?
    let roles: [RoleInfo]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case icon
        case description
        case memberCount = "approximate_member_count"
        case presenceCount = "approximate_presence_count"
        case channels
        case roles
    }
}

struct ChannelInfo: Codable, Identifiable {
    let id: String
    let name: String
    let type: Int
    let position: Int?
    let parentId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
        case position
        case parentId = "parent_id"
    }
    
    var channelType: ChannelType {
        ChannelType(rawValue: type) ?? .unknown
    }
}

struct RoleInfo: Codable, Identifiable {
    let id: String
    let name: String
    let color: Int
    let position: Int
    let permissions: String
    let managed: Bool?
    let mentionable: Bool?
    
    var hexColor: String {
        String(format: "#%06X", color)
    }
}

enum ChannelType: Int, Codable {
    case text = 0
    case dm = 1
    case voice = 2
    case group = 3
    case category = 4
    case announcement = 5
    case store = 6
    case announcementThread = 10
    case publicThread = 11
    case privateThread = 12
    case stageVoice = 13
    case directory = 14
    case forum = 15
    case unknown = -1
    
    var icon: String {
        switch self {
        case .text: return "text.bubble"
        case .voice, .stageVoice: return "mic"
        case .category: return "folder"
        case .announcement: return "megaphone"
        case .publicThread, .privateThread, .announcementThread: return "bubble.left.and.bubble.right"
        case .forum: return "list.bullet"
        default: return "questionmark"
        }
    }
    
    var name: String {
        switch self {
        case .text: return "Text"
        case .voice: return "Voice"
        case .category: return "Category"
        case .announcement: return "Announcement"
        case .publicThread: return "Thread"
        case .privateThread: return "Private Thread"
        case .stageVoice: return "Stage"
        case .forum: return "Forum"
        default: return "Other"
        }
    }
}
