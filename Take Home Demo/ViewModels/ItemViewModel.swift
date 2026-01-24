import Foundation
import CoreData
import Combine

class ItemViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var isLoading = false
    @Published var lastSyncDate: Date?
    
    private let repository: ItemRepository
    private let context: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()
    private var timer: AnyCancellable?
    
    init(repository: ItemRepository, context: NSManagedObjectContext) {
        self.repository = repository
        self.context = context
        
        setupFetchResultsController()
        startPolling()
    }
    
    private func setupFetchResultsController() {
        // Fetch items initially
        fetchItems()
        
        // Listen for context changes to update UI
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: context)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.fetchItems()
                    self?.lastSyncDate = Date()
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchItems() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.updatedAt, ascending: false)]
        
        do {
            items = try context.fetch(request)
        } catch {
            print("Fetch Error: \(error)")
        }
    }
    
    func startPolling() {
        timer?.cancel()
        timer = Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.repository.sync()
                }
            }
    }
    
    func refresh() async {
        await repository.sync()
    }
}
