//
//  DiscordMessage.swift
//  DiscordBotApp
//
//  Created by speedy on 2024/12/24.
//

import Foundation

struct DiscordMessage: Codable, Identifiable {

    let id: String
    let content: String?  // Even content could be optional (for embeds)
    let channelId: String?
    let timestamp: String?
    let author: MessageAuthor?
    let mentions: [MessageAuthor]?
    let mentionRoles: [String]?
    let mentionEveryone: Bool?
    let tts: Bool?
    let attachments: [MessageAttachment]?
    let embeds: [MessageEmbed]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case content
        case channelId = "channel_id"
        case timestamp
        case author
        case mentions
        case mentionRoles = "mention_roles"
        case mentionEveryone = "mention_everyone"
        case tts
        case attachments
        case embeds
    }
}

struct MessageAuthor: Codable {
    let id: String
    let username: String?
    let discriminator: String?
    let avatar: String?
    let bot: Bool?
}

struct MessageAttachment: Codable {
    let id: String
    let filename: String?
    let size: Int?
    let url: String?
    let proxyUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case filename
        case size
        case url
        case proxyUrl = "proxy_url"
    }
}

struct MessageEmbed: Codable {
    let title: String?
    let description: String?
    let url: String?
    let color: Int?
}

struct Embed: Codable {
    // if needed
    // this can be empty for now if you're not using embeds
}
