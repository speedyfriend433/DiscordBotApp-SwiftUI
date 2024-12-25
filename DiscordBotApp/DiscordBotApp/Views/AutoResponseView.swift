//
//  AutoResponseView.swift
//  DiscordBotApp
//
//  Created by speedy on 2024/12/25.
//

import SwiftUI

struct AutoResponseView: View {
    @ObservedObject var autoResponseManager: AutoResponseManager
    @State private var showingAddSheet = false
    @State private var searchText = ""
    
    var filteredResponses: [AutoResponse] {
        if searchText.isEmpty {
            return autoResponseManager.responses
        }
        return autoResponseManager.responses.filter {
            $0.trigger.localizedCaseInsensitiveContains(searchText) ||
            $0.response.localizedCaseInsensitiveContains(searchText) ||
            ($0.description?.localizedCaseInsensitiveContains(searchText) ?? false)
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
                    
                    if autoResponseManager.responses.isEmpty {
                        EmptyStateView()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredResponses) { response in
                                    AutoResponseItemView(
                                        response: response,
                                        autoResponseManager: autoResponseManager
                                    )
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Auto Responses")
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
                AutoResponseEditView(autoResponseManager: autoResponseManager)
            }
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 50))
                .foregroundColor(Theme.textSecondary)
            
            Text("No Auto Responses")
                .font(.title2)
                .foregroundColor(Theme.textPrimary)
            
            Text("Create your first auto response by tapping the + button")
                .foregroundColor(Theme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct AutoResponseItemView: View {
    let response: AutoResponse
    @ObservedObject var autoResponseManager: AutoResponseManager
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(response.isEnabled ? Theme.success : Theme.textSecondary)
                    .frame(width: 8, height: 8)
                
                Text(response.trigger)
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
                
                Menu {
                    Button(action: { showingEditSheet = true }) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(
                        action: { autoResponseManager.toggleResponse(response) }
                    ) {
                        Label(
                            response.isEnabled ? "Disable" : "Enable",
                            systemImage: response.isEnabled ? "pause.fill" : "play.fill"
                        )
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
            
            Text(response.response)
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
            
            if let description = response.description {
                Text(description)
                    .font(.caption)
                    .foregroundColor(Theme.accent)
            }
            
            HStack {
                if response.isRegex {
                    Label("Regex", systemImage: "textformat")
                        .font(.caption)
                        .foregroundColor(Theme.accent)
                }
                
                if response.caseSensitive {
                    Label("Case Sensitive", systemImage: "textformat.size")
                        .font(.caption)
                        .foregroundColor(Theme.accent)
                }
                
                Spacer()
                
                if let lastTriggered = response.lastTriggered {
                    Text("Last triggered: \(lastTriggered.formatted())")
                        .font(.caption2)
                        .foregroundColor(Theme.textSecondary)
                }
            }
        }
        .padding()
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadius)
        .sheet(isPresented: $showingEditSheet) {
            AutoResponseEditView(
                autoResponseManager: autoResponseManager,
                editingResponse: response
            )
        }
        .alert("Delete Auto Response", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                autoResponseManager.deleteResponse(response)
            }
        } message: {
            Text("Are you sure you want to delete this auto response?")
        }
    }
}
