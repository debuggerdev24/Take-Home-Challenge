import SwiftUI

struct GroceryDetailView: View {
    let item: Item
    
    var body: some View {
        List {
            Section(header: Text("Overview")) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(item.title ?? "Unknown")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    HStack {
                        statusBadge
                        Spacer()
                        Text(item.updatedAt?.formatted(date: .abbreviated, time: .shortened) ?? "")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            if let detail = item.detail {
                Section(header: Text("Description")) {
                    Text(detail)
                        .font(.body)
                        .foregroundColor(.primary)
                }
            }
            
            Section(header: Text("Raw Data")) {
                HStack {
                    Text("ID")
                        .fontWeight(.medium)
                    Spacer()
                    Text(item.id ?? "N/A")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Item Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var statusBadge: some View {
        Text(item.status?.replacingOccurrences(of: "_", with: " ").capitalized ?? "New")
            .font(.caption)
            .fontWeight(.bold)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.1))
            .foregroundColor(statusColor)
            .clipShape(Capsule())
    }
    
    private var statusColor: Color {
        switch item.status {
        case "new": return .blue
        case "in_progress": return .orange
        case "done": return .green
        case "cancelled": return .red
        default: return .gray
        }
    }
}
