//
//  DiscordError.swift
//  DiscordBotApp
//
//  Created by speedy on 2024/12/24.
//

import Foundation

enum DiscordError: LocalizedError {
    case invalidResponse
    case rateLimited(retryAfter: Int)
    case unauthorized
    case networkError
    case invalidData
    case serverError(Int)
    case custom(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from Discord"
        case .rateLimited(let retryAfter):
            return "Rate limited. Try again in \(retryAfter) seconds"
        case .unauthorized:
            return "Invalid Bot Token or unauthorized access"
        case .networkError:
            return "Network connection error"
        case .invalidData:
            return "Invalid data received"
        case .serverError(let code):
            return "Server error (Code: \(code))"
        case .custom(let message):
            return message
        }
    }
}
