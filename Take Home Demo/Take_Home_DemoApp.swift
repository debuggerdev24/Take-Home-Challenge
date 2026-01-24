//
//  Take_Home_DemoApp.swift
//  Take Home Demo
//
//  Created by test on 24/01/26.
//

import SwiftUI

@main
struct Take_Home_DemoApp: App {
    let persistenceController = PersistenceController.shared
    let repository: ItemRepository
    @StateObject var viewModel: ItemViewModel
    
    init() {
        let context = persistenceController.container.viewContext
        let network = MockNetworkClient()
        let repo = ItemRepository(context: context, networkClient: network)
        self.repository = repo
        self._viewModel = StateObject(wrappedValue: ItemViewModel(repository: repo, context: context))
    }

    var body: some Scene {
        WindowGroup {
            GroceryListView(viewModel: viewModel, repository: repository)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
