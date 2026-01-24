import XCTest
import CoreData
@testable import Take_Home_Demo

final class ItemRepositoryTests: XCTestCase {
    var repository: ItemRepository!
    var mockNetwork: MockNetworkClient!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        let container = NSPersistentContainer(name: "Take_Home_Demo")
        container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        container.loadPersistentStores { _, _ in }
        context = container.viewContext
        mockNetwork = MockNetworkClient()
        repository = ItemRepository(context: context, networkClient: mockNetwork)
    }
    
    func testSyncPersistsData() async throws {
        // Given
        let initialCount = try context.count(for: Item.fetchRequest())
        XCTAssertEqual(initialCount, 0)
        
        // When
        await repository.sync()
        
        // Then
        let finalCount = try context.count(for: Item.fetchRequest())
        XCTAssertGreaterThan(finalCount, 0)
    }
    
    func testMergeLogicUpdatesExistingItem() async throws {
        // Given: An item already exists
        let item = Item(context: context)
        item.id = "1"
        item.title = "Old Title"
        item.status = "new"
        item.updatedAt = Date().addingTimeInterval(-1000)
        try context.save()
        
        // When: Syncing with a newer remote item
        // (MockNetworkClient has an item with id "1")
        await repository.sync()
        
        // Then: The item should be updated
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", "1")
        let results = try context.fetch(request)
        XCTAssertEqual(results.first?.title, "Apples") // From MockNetworkClient
    }
}
