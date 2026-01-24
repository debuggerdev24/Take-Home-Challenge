import Foundation
import CoreData
import Combine

class ItemRepository: ObservableObject {
    private let context: NSManagedObjectContext
    private let networkClient: NetworkClientProtocol
    
    @Published var isSyncing: Bool = false
    @Published var lastError: Error?
    
    init(context: NSManagedObjectContext, networkClient: NetworkClientProtocol) {
        self.context = context
        self.networkClient = networkClient
    }
    
    @MainActor
    func sync() async {
        isSyncing = true
        defer { isSyncing = false }
        
        do {
            let remoteItems = try await networkClient.fetchItems()
            try await mergeItems(remoteItems)
        } catch {
            lastError = error
            print("Sync Error: \(error.localizedDescription)")
        }
    }
    
    private func mergeItems(_ remoteItems: [GroceryItem]) async throws {
        try await context.perform {
            for remoteItem in remoteItems {
                let request: NSFetchRequest<Item> = Item.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", remoteItem.id)
                
                let results = try self.context.fetch(request)
                
                if let existingItem = results.first {
                    // Update only if remote is newer
                    if remoteItem.updatedAt > existingItem.updatedAt ?? .distantPast {
                        existingItem.title = remoteItem.title
                        existingItem.status = remoteItem.status
                        existingItem.detail = remoteItem.detail
                        existingItem.updatedAt = remoteItem.updatedAt
                    }
                } else {
                    // Insert new item
                    let newItem = Item(context: self.context)
                    newItem.id = remoteItem.id
                    newItem.title = remoteItem.title
                    newItem.status = remoteItem.status
                    newItem.detail = remoteItem.detail
                    newItem.updatedAt = remoteItem.updatedAt
                }
            }
            
            if self.context.hasChanges {
                try self.context.save()
            }
        }
    }
}
