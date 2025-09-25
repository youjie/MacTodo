import SwiftUI
import Combine

class TodoManager: ObservableObject {
    @Published var tasks: [Task] = []
    @Published var selectedTaskIds: Set<UUID> = []
    @Published var showNewTaskView = false
    @Published var currentFilter: TaskFilter = .all
    @Published var searchText = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadTasks()
        
        // 自动保存任务的变化
        $tasks
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveTasks()
            }
            .store(in: &cancellables)
    }
    
    var filteredTasks: [Task] {
        tasks
            .filter { task in
                switch currentFilter {
                case .all: return true
                case .active: return !task.isCompleted
                case .completed: return task.isCompleted
                case .today: 
                    if let dueDate = task.dueDate {
                        return Calendar.current.isDateInToday(dueDate)
                    }
                    return false
                case .upcoming:
                    if let dueDate = task.dueDate {
                        return dueDate > Date() && !Calendar.current.isDateInToday(dueDate)
                    }
                    return false
                }
            }
            .filter { task in
                if searchText.isEmpty { return true }
                return task.title.localizedCaseInsensitiveContains(searchText) ||
                       task.notes.localizedCaseInsensitiveContains(searchText)
            }
            .sorted { task1, task2 in
                if task1.isCompleted != task2.isCompleted {
                    return !task1.isCompleted
                }
                
                if task1.priority != task2.priority {
                    return task1.priority.rawValue > task2.priority.rawValue
                }
                
                if let date1 = task1.dueDate, let date2 = task2.dueDate {
                    return date1 < date2
                } else if task1.dueDate != nil {
                    return true
                } else if task2.dueDate != nil {
                    return false
                }
                
                return task1.creationDate < task2.creationDate
            }
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }
    
    func deleteTask(withId id: UUID) {
        tasks.removeAll { $0.id == id }
        selectedTaskIds.remove(id)
    }
    
    func toggleTaskCompletion(taskId: UUID) {
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[index].isCompleted.toggle()
            tasks[index].completionDate = tasks[index].isCompleted ? Date() : nil
        }
    }
    
    func completeSelectedTasks() {
        for id in selectedTaskIds {
            if let index = tasks.firstIndex(where: { $0.id == id }) {
                tasks[index].isCompleted = true
                tasks[index].completionDate = Date()
            }
        }
        selectedTaskIds.removeAll()
    }
    
    func deleteSelectedTasks() {
        tasks.removeAll { selectedTaskIds.contains($0.id) }
        selectedTaskIds.removeAll()
    }
    
    func completeAllTasks() {
        for index in tasks.indices {
            tasks[index].isCompleted = true
            tasks[index].completionDate = Date()
        }
        selectedTaskIds.removeAll()
    }
    
    // MARK: - 持久化
    
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "tasks")
        }
    }
    
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: "tasks") {
            if let decoded = try? JSONDecoder().decode([Task].self, from: data) {
                tasks = decoded
                return
            }
        }
        
        // 如果没有保存的任务，创建一些示例任务
        tasks = [
            Task(title: "欢迎使用MacTodo", notes: "这是一个示例任务，您可以添加、编辑和删除任务。", priority: .medium),
            Task(title: "尝试添加新任务", notes: "点击左下角的+按钮或使用Command+N快捷键添加新任务。", priority: .high, dueDate: Date().addingTimeInterval(86400)),
            Task(title: "探索更多功能", notes: "尝试使用标签、优先级和截止日期来组织您的任务。", priority: .low, dueDate: Date().addingTimeInterval(172800))
        ]
    }
}
