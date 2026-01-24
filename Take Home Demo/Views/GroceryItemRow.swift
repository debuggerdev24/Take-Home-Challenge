import SwiftUI

struct GroceryItemRow: View {
    let item: Item
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Status Indicator
            statusCircle
                .frame(width: 12, height: 12)
                .padding(.top, 6)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title ?? "Unknown")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let detail = item.detail {
                    Text(detail)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Text(item.status?.replacingOccurrences(of: "_", with: " ").capitalized ?? "New")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(statusColor.opacity(0.1))
                        .foregroundColor(statusColor)
                        .cornerRadius(4)
                    
                    Spacer()
                    
                    Text(item.updatedAt?.timeAgoDisplay() ?? "")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var statusCircle: some View {
        Circle()
            .fill(statusColor)
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

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
