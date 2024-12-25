//
//  CommandExecuteView.swift
//  DiscordBotApp
//
//  Created by speedy on 2024/12/25.
//

import SwiftUI

struct CommandExecuteView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var commandManager: CommandManager
    let command: CustomCommand
    
    @State private var parameters: [String: String] = [:]
    @State private var channelId = ""
    @State private var isLoading = false
    @State private var error: Error?
    @State private var showError = false
    @State private var showSuccess = false
    
    init(command: CustomCommand, commandManager: CommandManager) {
        self.command = command
        self.commandManager = commandManager
        
        // Initialize parameters with default values
        var initialParams: [String: String] = [:]
        for param in command.parameters {
            initialParams[param.name] = param.defaultValue ?? ""
        }
        _parameters = State(initialValue: initialParams)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Channel ID Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("CHANNEL ID")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                            
                            CustomTextField(
                                placeholder: "Enter channel ID",
                                text: $channelId
                            )
                        }
                        
                        // Parameters
                        if !command.parameters.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("PARAMETERS")
                                    .font(.caption)
                                    .foregroundColor(Theme.textSecondary)
                                
                                ForEach(command.parameters) { param in
                                    ParameterInputField(
                                        parameter: param,
                                        value: Binding(
                                            get: { parameters[param.name] ?? "" },
                                            set: { parameters[param.name] = $0 }
                                        )
                                    )
                                }
                            }
                        }
                        
                        // Command Preview
                        VStack(alignment: .leading, spacing: 8) {
                            Text("COMMAND PREVIEW")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                            
                            Text(formatCommand())
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(Theme.textPrimary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Theme.inputBackground)
                                .cornerRadius(Theme.cornerRadius)
                        }
                        
                        // Execute Button
                        Button(action: executeCommand) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Execute Command")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canExecute ? Theme.accent : Theme.textSecondary)
                        .foregroundColor(.white)
                        .cornerRadius(Theme.cornerRadius)
                        .disabled(!canExecute || isLoading)
                    }
                    .padding()
                }
            }
            .navigationTitle("Execute Command")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(error?.localizedDescription ?? "Unknown error occurred")
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Command executed successfully!")
            }
        }
    }
    
    private var canExecute: Bool {
        guard !channelId.isEmpty else { return false }
        
        for param in command.parameters where param.isRequired {
            guard let value = parameters[param.name], !value.isEmpty else {
                return false
            }
        }
        
        return true
    }
    
    private func formatCommand() -> String {
        var result = command.command
        
        // Replace parameter placeholders with values
        for (name, value) in parameters {
            result = result.replacingOccurrences(of: "{\(name)}", with: value)
        }
        
        return result
    }
    
    private func executeCommand() {
        isLoading = true
        
        Task {
            do {
                let formattedCommand = formatCommand()

                commandManager.updateLastUsed(for: command)
                
                let _ = try await DiscordAPI(botToken: "Your Discord API Key")
                    .sendMessage(channelId: channelId, content: formattedCommand)
                
                isLoading = false
                showSuccess = true
            } catch {
                self.error = error
                isLoading = false
                showError = true
            }
        }
    }
}

struct ParameterInputField: View {
    let parameter: CommandParameter
    @Binding var value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(parameter.name)
                .font(.subheadline)
                .foregroundColor(Theme.textPrimary)
            
            if !parameter.description.isEmpty {
                Text(parameter.description)
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
            
            CustomTextField(
                placeholder: "Enter value",
                text: $value
            )
            
            if let defaultValue = parameter.defaultValue {
                Text("Default: \(defaultValue)")
                    .font(.caption)
                    .foregroundColor(Theme.accent)
            }
        }
        .padding()
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadius)
    }
}

#if DEBUG
struct CommandExecuteView_Previews: PreviewProvider {
    static var previews: some View {
        CommandExecuteView(
            command: CustomCommand(
                name: "Test Command",
                command: "!test {param1} {param2}",
                description: "Test command",
                parameters: [
                    CommandParameter(
                        name: "param1",
                        description: "First parameter"
                    ),
                    CommandParameter(
                        name: "param2",
                        description: "Second parameter",
                        isRequired: false,
                        defaultValue: "default"
                    )
                ]
            ),
            commandManager: CommandManager()
        )
    }
}
#endif
