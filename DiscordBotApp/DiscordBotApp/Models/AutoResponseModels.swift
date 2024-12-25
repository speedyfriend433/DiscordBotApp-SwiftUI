//
//  AutoResponseModels.swift
//  DiscordBotApp
//
//  Created by 지안 on 2024/12/25.
//

import Foundation

struct AutoResponse: Identifiable, Codable {
    let id: UUID
    var trigger: String
    var response: String
    var isRegex: Bool
    var isEnabled: Bool
    var description: String?
    var caseSensitive: Bool
    var createdAt: Date
    var lastTriggered: Date?
    
    init(
        trigger: String,
        response: String,
        isRegex: Bool = false,
        isEnabled: Bool = true,
        description: String? = nil,
        caseSensitive: Bool = false
    ) {
        self.id = UUID()
        self.trigger = trigger
        self.response = response
        self.isRegex = isRegex
        self.isEnabled = isEnabled
        self.description = description
        self.caseSensitive = caseSensitive
        self.createdAt = Date()
    }
}
