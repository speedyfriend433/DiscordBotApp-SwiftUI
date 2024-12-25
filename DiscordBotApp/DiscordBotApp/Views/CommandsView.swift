//
//  CommandsView.swift
//  DiscordBotApp
//
//  Created by speedy on 2024/12/25.
//

import SwiftUI

struct CommandsView: View {
    @ObservedObject var commandManager: CommandManager
    @State private var showingAddSheet = false
    @State private var searchText = ""
    
    var filteredCommands: [CustomCommand] {
        if searchText.isEmpty {
            return commandManager.commands
        }
        return commandManager.commands.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.primaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search bar
                    SearchBar(text: $searchText)
                        .padding()
                    
                    if commandManager.commands.isEmpty {
                        EmptyStateView()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredCommands) { command in
                                    CommandItemView(command: command, commandManager: commandManager)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Custom Commands")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddSheet = true }) {
                        Image(systemName: "plus")
                            .foregroundColor(Theme.accent)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                CommandEditView(commandManager: commandManager)
            }
        }
    }
}

struct CommandItemView: View {
    let command: CustomCommand
    @ObservedObject var commandManager: CommandManager
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingExecuteSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(command.name)
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
                
                Menu {
                    Button(action: { showingExecuteSheet = true }) {
                        Label("Execute", systemImage: "play.fill")
                    }
                    
                    Button(action: { showingEditSheet = true }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: { showingDeleteAlert = true }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(Theme.textSecondary)
                        .padding(8)
                        .background(Theme.inputBackground)
                        .cornerRadius(Theme.cornerRadius)
                }
            }
            
            Text(command.description)
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
            
            if !command.parameters.isEmpty {
                Text("Parameters: \(command.parameters.map { $0.name }.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(Theme.accent)
            }
            
            if let lastUsed = command.lastUsed {
                Text("Last used: \(lastUsed.formatted())")
                    .font(.caption2)
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .padding()
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadius)
        .sheet(isPresented: $showingEditSheet) {
            CommandEditView(commandManager: commandManager, editingCommand: command)
        }
        .sheet(isPresented: $showingExecuteSheet) {
            CommandExecuteView(command: command, commandManager: commandManager)
        }
        .alert("Delete Command", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                commandManager.deleteCommand(command)
            }
        } message: {
            Text("Are you sure you want to delete this command?")
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Theme.textSecondary)
            
            TextField("Search commands", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(Theme.textPrimary)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Theme.textSecondary)
                }
            }
        }
        .padding(8)
        .background(Theme.inputBackground)
        .cornerRadius(Theme.cornerRadius)
    }
}
