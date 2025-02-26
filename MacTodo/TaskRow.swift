import SwiftUI

struct TaskRow: View {
    @EnvironmentObject private var todoManager: TodoManager
    let task: Task
    @State private var isHovering = false
    @State private var showEditSheet = false
    
    var body: some View {
        HStack(spacing: 12) {
            // 完成按钮
            Button(action: {
                todoManager.toggleTaskCompletion(taskId: task.id)
            }) {
                ZStack {
                    Circle()
                        .strokeBorder(task.isCompleted ? Color.secondary : Color(task.priority.color), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    
                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // 任务内容
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(task.title)
                        .font(.headline)
                        .foregroundColor(task.isCompleted ? .secondary : .primary)
                        .strikethrough(task.isCompleted)
                    
                    Spacer()
                    
                    // 优先级标签
                    if !task.isCompleted {
                        priorityLabel
                    }
                    
                    // 截止日期
                    if let dueDate = task.dueDate, !task.isCompleted {
                        dueDateLabel(dueDate)
                    }
                }
                
                if !task.notes.isEmpty {
                    Text(task.notes)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                // 标签
                if !task.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(task.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.accentColor.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }
                    }
                    .frame(height: 24)
                }
            }
            
            // 编辑按钮
            if isHovering && !task.isCompleted {
                Button(action: {
                    showEditSheet = true
                }) {
                    Image(systemName: "pencil")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isHovering ? Color("HoverBackground") : Color.clear)
        .cornerRadius(8)
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovering = hovering
        }
        .sheet(isPresented: $showEditSheet) {
            TaskEditView(task: task) { updatedTask in
                if let updatedTask = updatedTask {
                    todoManager.updateTask(updatedTask)
                }
            }
            .frame(width: 500, height: 400)
        }
    }
    
    private var priorityLabel: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(Color(task.priority.color))
                .frame(width: 8, height: 8)
            
            Text(task.priority.title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Color(task.priority.color).opacity(0.1))
        .cornerRadius(4)
    }
    
    private func dueDateLabel(_ date: Date) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "calendar")
                .font(.caption)
            
            Text(dateFormatter.string(from: date))
                .font(.caption)
        }
        .foregroundColor(isOverdue(date) ? .red : .secondary)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(isOverdue(date) ? Color.red.opacity(0.1) : Color.secondary.opacity(0.1))
        .cornerRadius(4)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }
    
    private func isOverdue(_ date: Date) -> Bool {
        return date < Date() && !Calendar.current.isDateInToday(date)
    }
}
