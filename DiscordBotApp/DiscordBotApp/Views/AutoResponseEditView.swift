//
//  AutoResponseEditView.swift
//  DiscordBotApp
//
//  Created by speedy on 2024/12/25.
//

import SwiftUI

struct AutoResponseEditView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var autoResponseManager: AutoResponseManager
    
    @State private var trigger: String
    @State private var response: String
    @State private var description: String
    @State private var isRegex: Bool
    @State private var isEnabled: Bool
    @State private var caseSensitive: Bool
    
    let editingResponse: AutoResponse?
    
    init(autoResponseManager: AutoResponseManager, editingResponse: AutoResponse? = nil) {
        self.autoResponseManager = autoResponseManager
        self.editingResponse = editingResponse
        
        _trigger = State(initialValue: editingResponse?.trigger ?? "")
        _response = State(initialValue: editingResponse?.response ?? "")
        _description = State(initialValue: editingResponse?.description ?? "")
        _isRegex = State(initialValue: editingResponse?.isRegex ?? false)
        _isEnabled = State(initialValue: editingResponse?.isEnabled ?? true)
        _caseSensitive = State(initialValue: editingResponse?.caseSensitive ?? false)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.primaryBackground
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("TRIGGER")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                            
                            CustomTextField(
                                placeholder: "Enter trigger text",
                                text: $trigger
                            )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("RESPONSE")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                            
                            CustomTextField(
                                placeholder: "Enter response text",
                                text: $response
                            )
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("DESCRIPTION (OPTIONAL)")
                                .font(.caption)
                                .foregroundColor(Theme.textSecondary)
                            
                            CustomTextField(
                                placeholder: "Enter description",
                                text: $description
                            )
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("Use Regular Expression", isOn: $isRegex)
                            Toggle("Case Sensitive", isOn: $caseSensitive)
                            Toggle("Enabled", isOn: $isEnabled)
                        }
                        .foregroundColor(Theme.textPrimary)
                    }
                    .padding()
                }
            }
            .navigationTitle(editingResponse == nil ? "New Auto Response" : "Edit Auto Response")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveResponse()
                        dismiss()
                    }
                    .disabled(trigger.isEmpty || response.isEmpty)
                }
            }
        }
    }
    
    private func saveResponse() {
        let newResponse = AutoResponse(
            trigger: trigger,
            response: response,
            isRegex: isRegex,
            isEnabled: isEnabled,
            description: description.isEmpty ? nil : description,
            caseSensitive: caseSensitive
        )
        
        if editingResponse != nil {
            autoResponseManager.updateResponse(newResponse)
        } else {
            autoResponseManager.addResponse(newResponse)
        }
    }
}
