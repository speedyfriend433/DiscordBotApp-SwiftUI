//
//  StorageManager.swift
//  DiscordBotApp
//
//  Created by speedy on 2024/12/24.
//

import Foundation

class StorageManager: ObservableObject {
    @Published private(set) var items: [StorageItem] = []
    private let defaults = UserDefaults.standard
    private let storageKey = "storedItems"
    
    init() {
        loadItems()
    }
    
    func addItem(type: StorageItem.ItemType, value: String, label: String? = nil) {
        let newItem = StorageItem(
            id: UUID(),
            type: type,
            value: value,
            timestamp: Date(),
            label: label,
            memo: nil
        )
        items.append(newItem)
        saveItems()
    }
    
    func deleteItem(_ item: StorageItem) {
        items.removeAll { $0.id == item.id }
        saveItems()
    }
    
    func updateMemo(for item: StorageItem, memo: String?) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            var updatedItem = items[index]
            updatedItem.memo = memo
            items[index] = updatedItem
            saveItems()
        }
    }
    
    func updateLabel(for value: String, type: StorageItem.ItemType, label: String) {
        if let index = items.firstIndex(where: { $0.value == value && $0.type == type }) {
            var updatedItem = items[index]
            updatedItem.label = label
            items[index] = updatedItem
            saveItems()
        }
    }
    
    private func loadItems() {
        if let data = defaults.data(forKey: storageKey) {
            do {
                let decoder = JSONDecoder()
                items = try decoder.decode([StorageItem].self, from: data)
            } catch {
                print("Error loading items: \(error)")
                items = []
            }
        }
    }
    
    private func saveItems() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(items)
            defaults.set(data, forKey: storageKey)
        } catch {
            print("Error saving items: \(error)")
        }
    }
}
