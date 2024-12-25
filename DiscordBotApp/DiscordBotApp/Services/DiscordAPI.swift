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
    private var autoResponseManager: AutoResponseManager?
    
    init(botToken: String, autoResponseManager: AutoResponseManager? = nil) {
        self.botToken = botToken
        self.autoResponseManager = autoResponseManager
    }
    
    func updateToken(_ newToken: String) {
        self.botToken = newToken
    }
    
    func sendMessage(channelId: String, content: String) async throws -> DiscordMessage {

        if let autoResponseManager = self.autoResponseManager,
           let response = checkAutoResponses(for: content) {

            try await sendAutoResponse(channelId: channelId, response: response)
        }
        
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
    
    private func sendAutoResponse(channelId: String, response: AutoResponse) async throws -> DiscordMessage {
        guard let url = URL(string: "\(baseURL)/channels/\(channelId)/messages") else {
            throw DiscordError.invalidData
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bot \(botToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let messagePayload = ["content": response.response]
        request.httpBody = try? JSONEncoder().encode(messagePayload)
        
        let (data, httpResponse) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = httpResponse as? HTTPURLResponse else {
            throw DiscordError.invalidResponse
        }
        
        if (200...299).contains(httpResponse.statusCode) {
            self.autoResponseManager?.updateLastTriggered(response)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(DiscordMessage.self, from: data)
        } else {
            throw DiscordError.serverError(httpResponse.statusCode)
        }
    }
    
    private func checkAutoResponses(for message: String) -> AutoResponse? {
        guard let autoResponseManager = self.autoResponseManager else { return nil }
        
        return autoResponseManager.responses.first { response in
            guard response.isEnabled else { return false }
            
            if response.isRegex {

                do {
                    let regex = try NSRegularExpression(
                        pattern: response.trigger,
                        options: response.caseSensitive ? [] : [.caseInsensitive]
                    )
                    let range = NSRange(message.startIndex..<message.endIndex, in: message)
                    return regex.firstMatch(in: message, range: range) != nil
                } catch {
                    print("Invalid regex pattern: \(error)")
                    return false
                }
            } else {

                if response.caseSensitive {
                    return message.contains(response.trigger)
                } else {
                    return message.localizedCaseInsensitiveContains(response.trigger)
                }
            }
        }
    }
    
    func getServerIcon(serverId: String, iconHash: String) -> URL? {
        URL(string: "https://cdn.discordapp.com/icons/\(serverId)/\(iconHash).png")
    }
}

// MARK: - Extension

extension DiscordAPI {
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
}

