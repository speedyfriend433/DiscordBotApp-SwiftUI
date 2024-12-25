//
//  ParameterEditView.swift
//  DiscordBotApp
//
//  Created by speedy on 2024/12/25.
//

import SwiftUI

struct ParameterEditView: View {
    @Environment(\.dismiss) var dismiss
    let onSave: (CommandParameter) -> Void
    
    @State private var name = ""
    @State private var description = ""
    @State private var isRequired = true
    @State private var defaultValue = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.primaryBackground
                    .ignoresSafeArea()
                
                Form {
                    Section {
                        TextField("Parameter Name", text: $name)
                        TextField("Description", text: $description)
                    }
                    
                    Section {
                        Toggle("Required", isOn: $isRequired)
                        if !isRequired {
                            TextField("Default Value", text: $defaultValue)
                        }
                    }
                }
            }
            .navigationTitle("Add Parameter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let parameter = CommandParameter(
                            name: name,
                            description: description,
                            isRequired: isRequired,
                            defaultValue: defaultValue.isEmpty ? nil : defaultValue
                        )
                        onSave(parameter)
                        dismiss()
                    }
                    .disabled(name.isEmpty || description.isEmpty)
                }
            }
        }
    }
}
