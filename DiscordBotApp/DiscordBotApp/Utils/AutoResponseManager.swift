//
//  AutoResponseManager.swift
//  DiscordBotApp
//
//  Created by speedy on 2024/12/25.
//

import Foundation

class AutoResponseManager: ObservableObject {
    @Published private(set) var responses: [AutoResponse] = []
    private let defaults = UserDefaults.standard
    private let storageKey = "autoResponses"
    
    init() {
        loadResponses()
    }
    
    func addResponse(_ response: AutoResponse) {
        responses.append(response)
        saveResponses()
    }
    
    func updateResponse(_ response: AutoResponse) {
        if let index = responses.firstIndex(where: { $0.id == response.id }) {
            responses[index] = response
            saveResponses()
        }
    }
    
    func deleteResponse(_ response: AutoResponse) {
        responses.removeAll { $0.id == response.id }
        saveResponses()
    }
    
    func toggleResponse(_ response: AutoResponse) {
        if let index = responses.firstIndex(where: { $0.id == response.id }) {
            var updatedResponse = response
            updatedResponse.isEnabled.toggle()
            responses[index] = updatedResponse
            saveResponses()
        }
    }
    
    func updateLastTriggered(_ response: AutoResponse) {
        if let index = responses.firstIndex(where: { $0.id == response.id }) {
            var updatedResponse = response
            updatedResponse.lastTriggered = Date()
            responses[index] = updatedResponse
            saveResponses()
        }
    }
    
    private func loadResponses() {
        if let data = defaults.data(forKey: storageKey) {
            do {
                responses = try JSONDecoder().decode([AutoResponse].self, from: data)
            } catch {
                print("Error loading auto responses: \(error)")
                responses = []
            }
        }
    }
    
    private func saveResponses() {
        do {
            let data = try JSONEncoder().encode(responses)
            defaults.set(data, forKey: storageKey)
        } catch {
            print("Error saving auto responses: \(error)")
        }
    }
}
