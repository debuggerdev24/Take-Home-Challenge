import Foundation

struct GroceryItem: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let status: String
    let detail: String?
    let updatedAt: Date
    
    enum Status: String, Codable, CaseIterable {
        case new
        case inProgress = "in_progress"
        case done
        case cancelled
    }
}
