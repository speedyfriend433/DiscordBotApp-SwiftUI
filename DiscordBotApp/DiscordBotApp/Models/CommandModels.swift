//
//  CommandModels.swift
//  DiscordBotApp
//
//  Created by speedy on 2024/12/25.
//

import Foundation

struct CustomCommand: Identifiable, Codable {
    let id: UUID
    var name: String
    var command: String
    var description: String
    var parameters: [CommandParameter]
    var createdAt: Date
    var lastUsed: Date?
    
    init(name: String, command: String, description: String, parameters: [CommandParameter]) {
        self.id = UUID()
        self.name = name
        self.command = command
        self.description = description
        self.parameters = parameters
        self.createdAt = Date()
    }
}

struct CommandParameter: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var isRequired: Bool
    var defaultValue: String?
    
    init(name: String, description: String, isRequired: Bool = true, defaultValue: String? = nil) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.isRequired = isRequired
        self.defaultValue = defaultValue
    }
}
