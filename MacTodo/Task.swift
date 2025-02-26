import Foundation

struct Task: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var notes: String
    var isCompleted: Bool = false
    var priority: Priority
    var dueDate: Date?
    var tags: [String] = []
    var creationDate: Date = Date()
    var completionDate: Date?
    
    enum Priority: Int, Codable, CaseIterable {
        case low = 0
        case medium = 1
        case high = 2
        
        var title: String {
            switch self {
            case .low: return "低"
            case .medium: return "中"
            case .high: return "高"
            }
        }
        
        var color: String {
            switch self {
            case .low: return "priorityLow"
            case .medium: return "priorityMedium"
            case .high: return "priorityHigh"
            }
        }
    }
}

enum TaskFilter {
    case all
    case active
    case completed
    case today
    case upcoming
    
    var title: String {
        switch self {
        case .all: return "全部"
        case .active: return "进行中"
        case .completed: return "已完成"
        case .today: return "今天"
        case .upcoming: return "即将到期"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "list.bullet"
        case .active: return "clock"
        case .completed: return "checkmark.circle"
        case .today: return "calendar"
        case .upcoming: return "calendar.badge.clock"
        }
    }
}
