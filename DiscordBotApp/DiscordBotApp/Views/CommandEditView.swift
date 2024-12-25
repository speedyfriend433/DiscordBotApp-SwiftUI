//
//  CommandEditView.swift
//  DiscordBotApp
//
//  Created by speedy on 2024/12/25.
//

import SwiftUI

struct CommandEditView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var commandManager: CommandManager
    
    @State private var name: String
    @State private var command: String
    @State private var description: String
    @State private var parameters: [CommandParameter]
    @State private var showingAddParameter = false
    
    let editingCommand: CustomCommand?
    
    init(commandManager: CommandManager, editingCommand: CustomCommand? = nil) {
        self.commandManager = commandManager
        self.editingCommand = editingCommand
        _name = State(initialValue: editingCommand?.name ?? "")
        _command = State(initialValue: editingCommand?.command ?? "")
        _description = State(initialValue: editingCommand?.description ?? "")
        _parameters = State(initialValue: editingCommand?.parameters ?? [])
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("COMMAND NAME")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                            
                            CustomTextField(placeholder: "Enter command name", text: $name)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("COMMAND")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                            
                            CustomTextField(placeholder: "Enter command", text: $command)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DESCRIPTION")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                            
                            CustomTextField(placeholder: "Enter description", text: $description)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("PARAMETERS")
                                    .font(.caption)
                                    .foregroundColor(Theme.textSecondary)
                                
                                Spacer()
                                
                                Button(action: { showingAddParameter = true }) {
                                    Image(systemName: "plus")
                                        .foregroundColor(Theme.accent)
                                }
                            }
                            
                            ForEach(parameters) { parameter in
                                ParameterItemView(parameter: parameter) { param in
                                    parameters.removeAll { $0.id == param.id }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(editingCommand == nil ? "New Command" : "Edit Command")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCommand()
                        dismiss()
                    }
                    .disabled(name.isEmpty || command.isEmpty)
                }
            }
            .sheet(isPresented: $showingAddParameter) {
                ParameterEditView { parameter in
                    parameters.append(parameter)
                }
            }
        }
    }
    
    private func saveCommand() {
            let newCommand = CustomCommand(
                name: name,
                command: command,
                description: description,
                parameters: parameters
            )
            
            if editingCommand != nil {
                commandManager.updateCommand(newCommand)
            } else {
                commandManager.addCommand(newCommand)
            }
        }
    }

struct ParameterItemView: View {
    let parameter: CommandParameter
    let onDelete: (CommandParameter) -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(parameter.name)
                    .foregroundColor(Theme.textPrimary)
                
                Text(parameter.description)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                
                if let defaultValue = parameter.defaultValue {
                    Text("Default: \(defaultValue)")
                        .font(.caption)
                        .foregroundColor(Theme.accent)
                }
            }
            
            Spacer()
            
            Button(action: { onDelete(parameter) }) {
                Image(systemName: "trash")
                    .foregroundColor(Theme.error)
            }
        }
        .padding()
        .background(Theme.inputBackground)
        .cornerRadius(Theme.cornerRadius)
    }
}
