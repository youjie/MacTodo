import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var todoManager: TodoManager
    @State private var selectedSidebarItem: TaskFilter = .all
    @State private var isHoveringAddButton = false
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationView {
            // 侧边栏
            sidebar
                .frame(minWidth: 220)
            
            // 主内容区
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 搜索栏
                    searchBar
                    
                    // 任务列表
                    taskList
                }
            }
        }
        .navigationTitle("MacTodo")
        .sheet(isPresented: $todoManager.showNewTaskView) {
            TaskEditView(task: nil) { newTask in
                if let task = newTask {
                    todoManager.addTask(task)
                }
                todoManager.showNewTaskView = false
            }
            .frame(width: 500, height: 400)
        }
    }
    
    private var sidebar: some View {
        List(selection: $selectedSidebarItem) {
            Section(header: Text("过滤器")) {
                ForEach([TaskFilter.all, .active, .completed, .today, .upcoming], id: \.self) { filter in
                    HStack {
                        Image(systemName: filter.icon)
                            .foregroundColor(Color.accentColor)
                            .frame(width: 24)
                        Text(filter.title)
                        Spacer()
                        if filter != .completed {
                            let count = todoManager.tasks.filter { 
                                switch filter {
                                case .all: return !$0.isCompleted
                                case .active: return !$0.isCompleted
                                case .today: 
                                    if let dueDate = $0.dueDate {
                                        return Calendar.current.isDateInToday(dueDate) && !$0.isCompleted
                                    }
                                    return false
                                case .upcoming:
                                    if let dueDate = $0.dueDate {
                                        return dueDate > Date() && !Calendar.current.isDateInToday(dueDate) && !$0.isCompleted
                                    }
                                    return false
                                default: return false
                                }
                            }.count
                            
                            if count > 0 {
                                Text("\(count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.secondary.opacity(0.2))
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .tag(filter)
                }
            }
            
            Spacer()
                .frame(height: 20)
            
            Button(action: {
                todoManager.showNewTaskView = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.accentColor)
                    Text("新建任务")
                    Spacer()
                    Text("⌘N")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding(.vertical, 6)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .listStyle(SidebarListStyle())
        .onChange(of: selectedSidebarItem) { newValue in
            todoManager.currentFilter = newValue
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("搜索任务...", text: $todoManager.searchText)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !todoManager.searchText.isEmpty {
                Button(action: {
                    todoManager.searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(8)
        .background(Color("SearchBackground"))
        .cornerRadius(8)
        .padding()
    }
    
    private var taskList: some View {
        List(selection: $todoManager.selectedTaskIds) {
            if todoManager.filteredTasks.isEmpty {
                emptyStateView
            } else {
                ForEach(todoManager.filteredTasks) { task in
                    TaskRow(task: task)
                        .contextMenu {
                            Button(action: {
                                todoManager.toggleTaskCompletion(taskId: task.id)
                            }) {
                                Label(task.isCompleted ? "标记为未完成" : "标记为已完成", 
                                      systemImage: task.isCompleted ? "circle" : "checkmark.circle")
                            }
                            
                            Button(action: {
                                todoManager.deleteTask(withId: task.id)
                            }) {
                                Label("删除", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(emptyStateMessage)
                .font(.title2)
                .foregroundColor(.secondary)
            
            Button(action: {
                todoManager.showNewTaskView = true
            }) {
                Text("添加新任务")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .listRowBackground(Color.clear)
    }
    
    private var emptyStateMessage: String {
        if !todoManager.searchText.isEmpty {
            return "没有找到匹配的任务"
        }
        
        switch todoManager.currentFilter {
        case .all:
            return "没有任务，享受轻松的一天吧！"
        case .active:
            return "没有进行中的任务"
        case .completed:
            return "没有已完成的任务"
        case .today:
            return "今天没有待办任务"
        case .upcoming:
            return "没有即将到期的任务"
        }
    }
}
