//
//  DiscordAPI.swift
//  DiscordBotApp
//
//  Created by speedy on 2024/12/24.
//

import Foundation

class DiscordAPI: ObservableObject {
    private let baseURL = "https://discord.com/api/v10"
    private var botToken: String
    
    init(botToken: String) {
        self.botToken = botToken
    }
    
    func updateToken(_ newToken: String) {
        self.botToken = newToken
    }
    
    func getServerInfo(serverId: String) async throws -> ServerInfo {
        guard let url = URL(string: "\(baseURL)/guilds/\(serverId)?with_counts=true") else {
            throw DiscordError.invalidData
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bot \(botToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Server Info Response: \(responseString)")
            }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DiscordError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(ServerInfo.self, from: data)
        case 401:
            throw DiscordError.unauthorized
        case 403:
            throw DiscordError.custom("Bot doesn't have required permissions")
        case 404:
            throw DiscordError.custom("Server not found")
        default:
            throw DiscordError.serverError(httpResponse.statusCode)
        }
    }
    
    func sendMessage(channelId: String, content: String) async throws -> DiscordMessage {
        guard let url = URL(string: "\(baseURL)/channels/\(channelId)/messages") else {
            throw DiscordError.invalidData
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bot \(botToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let messagePayload = ["content": content]
        request.httpBody = try? JSONEncoder().encode(messagePayload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DiscordError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(DiscordMessage.self, from: data)
        case 401:
            throw DiscordError.unauthorized
        case 429:
            throw DiscordError.rateLimited(retryAfter: 1)
        default:
            throw DiscordError.serverError(httpResponse.statusCode)
        }
    }
}

/*extension DiscordAPI {
    func getServerInfo(serverId: String) async throws -> ServerInfo {
        guard let url = URL(string: "\(baseURL)/guilds/\(serverId)?with_counts=true") else {
            throw DiscordError.invalidData
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bot \(botToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DiscordError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            let decoder = JSONDecoder()
            return try decoder.decode(ServerInfo.self, from: data)
        case 401:
            throw DiscordError.unauthorized
        case 404:
            throw DiscordError.invalidData
        default:
            throw DiscordError.serverError(httpResponse.statusCode)
        }
    }*/
    
    func getServerIcon(serverId: String, iconHash: String) -> URL? {
        URL(string: "https://cdn.discordapp.com/icons/\(serverId)/\(iconHash).png")
    }

