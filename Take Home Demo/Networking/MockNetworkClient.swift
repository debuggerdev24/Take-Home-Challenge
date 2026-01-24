import Foundation

protocol NetworkClientProtocol {
    func fetchItems() async throws -> [GroceryItem]
}

class MockNetworkClient: NetworkClientProtocol {
    private var internalItems: [GroceryItem] = [
        GroceryItem(id: "1", title: "Apples", status: "new", detail: "Gala apples from the local farm.", updatedAt: Date().addingTimeInterval(-3600)),
        GroceryItem(id: "2", title: "Milk", status: "in_progress", detail: "Whole milk, 1 gallon.", updatedAt: Date().addingTimeInterval(-7200)),
        GroceryItem(id: "3", title: "Bread", status: "done", detail: "Whole wheat bread.", updatedAt: Date().addingTimeInterval(-10800))
    ]
    
    func fetchItems() async throws -> [GroceryItem] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Randomly update or add an item to simulate "real-time" changes
        let chance = Int.random(in: 0...10)
        if chance > 7 {
            updateRandomItem()
        } else if chance > 5 {
            addNewItem()
        }
        
        return internalItems
    }
    
    private func updateRandomItem() {
        guard let index = internalItems.indices.randomElement() else { return }
        let item = internalItems[index]
        let newStatus = GroceryItem.Status.allCases.randomElement()?.rawValue ?? "new"
        internalItems[index] = GroceryItem(
            id: item.id,
            title: item.title,
            status: newStatus,
            detail: item.detail,
            updatedAt: Date()
        )
        print("Mock: Updated item \(item.id) to status \(newStatus)")
    }
    
    private func addNewItem() {
        let newId = UUID().uuidString
        let newItem = GroceryItem(
            id: newId,
            title: "New Item \(internalItems.count + 1)",
            status: "new",
            detail: "Automatically added item.",
            updatedAt: Date()
        )
        internalItems.append(newItem)
        print("Mock: Added new item \(newId)")
    }
}
