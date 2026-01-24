import SwiftUI

struct GroceryListView: View {
    @StateObject var viewModel: ItemViewModel
    @ObservedObject var repository: ItemRepository
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                
                if viewModel.items.isEmpty && !repository.isSyncing {
                    emptyState
                } else {
                    List {
                        ForEach(viewModel.items) { item in
                            NavigationLink(destination: GroceryDetailView(item: item)) {
                                GroceryItemRow(item: item)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
                
                if repository.isSyncing && viewModel.items.isEmpty {
                    ProgressView("Fetching items...")
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Grocery List")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    syncIndicator
                }
            }
        }
    }
    
    private var syncIndicator: some View {
        HStack(spacing: 4) {
            if repository.isSyncing {
                ProgressView()
                    .scaleEffect(0.7)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.caption)
            }
            
            if let lastSync = viewModel.lastSyncDate {
                Text("Synced \(lastSync.formatted(.dateTime.hour().minute().second()))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart.badge.minus")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No items found")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("Try pulling down to refresh or check your connection.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("Retry Sync") {
                Task {
                    await viewModel.refresh()
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
