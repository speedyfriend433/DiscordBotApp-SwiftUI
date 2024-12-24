//
//  WebSocketManager.swift
//  DiscordBotApp
//
//  Created by speedy on 2024/12/24.
//

import Foundation

class WebSocketManager: ObservableObject {
    private var webSocket: URLSessionWebSocketTask?
    private let botToken: String
    
    @Published var isConnected = false
    
    init(botToken: String) {
        self.botToken = botToken
        setupWebSocket()
    }
    
    private func setupWebSocket() {
        guard let url = URL(string: "wss://gateway.discord.gg/?v=10&encoding=json") else { return }
        let session = URLSession(configuration: .default)
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
        receiveMessage()
    }
    
    private func receiveMessage() {
        webSocket?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received: \(text)")
                case .data(let data):
                    print("Received data: \(data)")
                @unknown default:
                    break
                }
                self?.receiveMessage()
            case .failure(let error):
                print("WebSocket error: \(error)")
            }
        }
    }
}
