//
//  RateLimiter.swift
//  DiscordBotApp
//
//  Created by speedy on 2024/12/24.
//

import Foundation

struct RateLimiter {
    private var lastRequest: Date?
    private let minimumInterval: TimeInterval
    
    init(minimumInterval: TimeInterval) {
        self.minimumInterval = minimumInterval
    }
    
    mutating func shouldMakeRequest() -> Bool {
        guard let last = lastRequest else {
            lastRequest = Date()
            return true
        }
        
        if Date().timeIntervalSince(last) >= minimumInterval {
            lastRequest = Date()
            return true
        }
        return false
    }
}
