//
//  CommandManager..swift
//  DiscordBotApp
//
//  Created by speedy on 2024/12/25.
//

import Foundation

class CommandManager: ObservableObject {
    @Published private(set) var commands: [CustomCommand] = []
    private let defaults = UserDefaults.standard
    private let storageKey = "customCommands"
    
    init() {
        loadCommands()
    }
    
    func addCommand(_ command: CustomCommand) {
        commands.append(command)
        saveCommands()
    }
    
    func updateCommand(_ command: CustomCommand) {
        if let index = commands.firstIndex(where: { $0.id == command.id }) {
            commands[index] = command
            saveCommands()
        }
    }
    
    func deleteCommand(_ command: CustomCommand) {
        commands.removeAll { $0.id == command.id }
        saveCommands()
    }
    
    func updateLastUsed(for command: CustomCommand) {
        if let index = commands.firstIndex(where: { $0.id == command.id }) {
            var updatedCommand = command
            updatedCommand.lastUsed = Date()
            commands[index] = updatedCommand
            saveCommands()
        }
    }
    
    private func loadCommands() {
        if let data = defaults.data(forKey: storageKey) {
            do {
                commands = try JSONDecoder().decode([CustomCommand].self, from: data)
            } catch {
                print("Error loading commands: \(error)")
                commands = []
            }
        }
    }
    
    private func saveCommands() {
        do {
            let data = try JSONEncoder().encode(commands)
            defaults.set(data, forKey: storageKey)
        } catch {
            print("Error saving commands: \(error)")
        }
    }
}
