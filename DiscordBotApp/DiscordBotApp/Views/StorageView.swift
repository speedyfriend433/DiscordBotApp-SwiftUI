//
//  StorageView.swift
//  DiscordBotApp
//
//  Created by speedy on 2024/12/24.
//

import SwiftUI

struct StorageView: View {
    @ObservedObject var storageManager: StorageManager
    @State private var selectedType: StorageItem.ItemType = .channelId
    @State private var showingCopiedAlert = false
    @State private var copiedItemType: StorageItem.ItemType?
    
    private let types: [StorageItem.ItemType] = [
        .channelId,
        .message,
        .token,
        .serverId
    ]
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                Theme.primaryBackground
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(types, id: \.self) { type in
                                TypeButton(
                                    type: type,
                                    isSelected: selectedType == type,
                                    action: { selectedType = type }
                                )
                            }
                        }
                        .padding()
                    }
                    .background(Theme.secondaryBackground)
                    
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(storageManager.items.filter { $0.type == selectedType }) { item in
                                StorageItemView(
                                    storageManager: storageManager,
                                    item: item
                                ) {
                                    copyToClipboard(item.value)
                                    copiedItemType = item.type
                                    showCopiedAlert()
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Storage")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(
                GeometryReader { geometry in
                    if showingCopiedAlert {
                        VStack {
                            Spacer()
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("\(copiedItemType?.title ?? "Item") copied!")
                            }
                            .padding()
                            .background(Theme.secondaryBackground)
                            .foregroundColor(Theme.success)
                            .cornerRadius(Theme.cornerRadius)
                            .padding(.horizontal)
                            .padding(.bottom, 60)
                        }
                        .frame(width: geometry.size.width)
                        .transition(.move(edge: .bottom))
                        .animation(.spring(), value: showingCopiedAlert)
                    }
                }
            )
        }
    }
    
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
    }
    
    private func showCopiedAlert() {
        showingCopiedAlert = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showingCopiedAlert = false
        }
    }
}

struct TypeButton: View {
    let type: StorageItem.ItemType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: type.icon)
                Text(type.title)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Theme.accent : Theme.inputBackground)
            .foregroundColor(isSelected ? .white : Theme.textSecondary)
            .cornerRadius(Theme.cornerRadius)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
}

struct StorageItemView: View {
    @ObservedObject var storageManager: StorageManager
    let item: StorageItem
    let copyAction: () -> Void
    
    @State private var showingMemoSheet = false
    @State private var memo: String
    @State private var showingDeleteAlert = false
    
    init(storageManager: StorageManager, item: StorageItem, copyAction: @escaping () -> Void) {
        self.storageManager = storageManager
        self.item = item
        self.copyAction = copyAction
        _memo = State(initialValue: item.memo ?? "")
    }
    
    var body: some View {
        HStack(spacing: 16) {

            Image(systemName: item.type.icon)
                .foregroundColor(Theme.accent)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                if let label = item.label {
                    Text(label)
                        .foregroundColor(Theme.textPrimary)
                        .fontWeight(.medium)
                }
                
                Text(item.type == .token ? "••••" + item.value.suffix(4) : item.value)
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(1)
                
                if let memo = item.memo, !memo.isEmpty {
                    Text(memo)
                        .font(.caption)
                        .foregroundColor(Theme.accent)
                        .lineLimit(2)
                }
                
                Text(item.timestamp.formatted())
                    .font(.caption2)
                    .foregroundColor(Theme.textSecondary.opacity(0.7))
            }
            
            Spacer()
            
            HStack(spacing: 12) {

                Button(action: { showingMemoSheet = true }) {
                    Image(systemName: item.memo == nil ? "square.and.pencil" : "note.text")
                        .foregroundColor(Theme.textSecondary)
                        .padding(8)
                        .background(Theme.inputBackground)
                        .cornerRadius(Theme.cornerRadius)
                }
                
                Button(action: copyAction) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(Theme.textSecondary)
                        .padding(8)
                        .background(Theme.inputBackground)
                        .cornerRadius(Theme.cornerRadius)
                }
                
                Button(action: { showingDeleteAlert = true }) {
                    Image(systemName: "trash")
                        .foregroundColor(Theme.error)
                        .padding(8)
                        .background(Theme.inputBackground)
                        .cornerRadius(Theme.cornerRadius)
                }
            }
        }
        .padding()
        .background(Theme.secondaryBackground)
        .cornerRadius(Theme.cornerRadius)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .alert("Delete Item", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                storageManager.deleteItem(item)
            }
        } message: {
            Text("Are you sure you want to delete this item?")
        }
        .sheet(isPresented: $showingMemoSheet) {
            MemoSheet(memo: $memo, isPresented: $showingMemoSheet) {
                storageManager.updateMemo(for: item, memo: memo.isEmpty ? nil : memo)
            }
        }
    }
}

struct MemoSheet: View {
    @Binding var memo: String
    @Binding var isPresented: Bool
    let onSave: () -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.primaryBackground.ignoresSafeArea()
                
                VStack {
                    TextEditor(text: $memo)
                        .foregroundColor(Theme.textPrimary)
                        .frame(maxWidth: .infinity, minHeight: 100)
                        .padding()
                        .background(Theme.inputBackground)
                        .cornerRadius(Theme.cornerRadius)
                        .padding()
                }
            }
            .navigationTitle("Add Memo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave()
                        isPresented = false
                    }
                }
            }
        }
    }
}

// MARK: - Preview Provider

#if DEBUG
struct StorageView_Previews: PreviewProvider {
    static var previews: some View {
        StorageView(storageManager: StorageManager())
    }
}
#endif
