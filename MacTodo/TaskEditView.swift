import SwiftUI

struct TaskEditView: View {
    let existingTask: Task?
    let onSave: (Task?) -> Void
    
    @State private var title: String
    @State private var notes: String
    @State private var priority: Task.Priority
    @State private var dueDate: Date?
    @State private var hasDueDate: Bool
    @State private var tags: [String]
    @State private var newTag: String = ""
    
    @Environment(\.presentationMode) private var presentationMode
    
    init(task: Task?, onSave: @escaping (Task?) -> Void) {
        self.existingTask = task
        self.onSave = onSave
        
        _title = State(initialValue: task?.title ?? "")
        _notes = State(initialValue: task?.notes ?? "")
        _priority = State(initialValue: task?.priority ?? .medium)
        _dueDate = State(initialValue: task?.dueDate)
        _hasDueDate = State(initialValue: task?.dueDate != nil)
        _tags = State(initialValue: task?.tags ?? [])
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text(existingTask == nil ? "新建任务" : "编辑任务")
                    .font(.headline)
                
                Spacer()
                
                Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                    onSave(nil)
                }
                .keyboardShortcut(.escape, modifiers: [])
                
                Button("保存") {
                    saveTask()
                }
                .keyboardShortcut(.return, modifiers: .command)
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .background(Color("HeaderBackground"))
            
            // 内容区
            ScrollView {
                VStack(spacing: 20) {
                    // 标题
                    VStack(alignment: .leading, spacing: 8) {
                        Text("标题")
                            .font(.headline)
                        
                        TextField("任务标题", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // 备注
                    VStack(alignment: .leading, spacing: 8) {
                        Text("备注")
                            .font(.headline)
                        
                        TextEditor(text: $notes)
                            .frame(height: 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    // 优先级
                    VStack(alignment: .leading, spacing: 8) {
                        Text("优先级")
                            .font(.headline)
                        
                        Picker("优先级", selection: $priority) {
                            ForEach(Task.Priority.allCases, id: \.self) { priority in
                                HStack {
                                    Circle()
                                        .fill(Color(priority.color))
                                        .frame(width: 12, height: 12)
                                    Text(priority.title)
                                }
                                .tag(priority)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // 截止日期
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("截止日期", isOn: $hasDueDate)
                            .font(.headline)
                        
                        if hasDueDate {
                            DatePicker("", selection: Binding(
                                get: { dueDate ?? Date() },
                                set: { dueDate = $0 }
                            ), displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .frame(maxHeight: 400)
                        }
                    }
                    
                    // 标签
                    VStack(alignment: .leading, spacing: 8) {
                        Text("标签")
                            .font(.headline)
                        
                        HStack {
                            TextField("添加标签", text: $newTag, onCommit: addTag)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button(action: addTag) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(newTag.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        
                        FlowLayout(spacing: 8) {
                            ForEach(tags, id: \.self) { tag in
                                HStack {
                                    Text(tag)
                                        .padding(.leading, 8)
                                        .padding(.trailing, 4)
                                        .padding(.vertical, 4)
                                    
                                    Button(action: {
                                        removeTag(tag)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.trailing, 4)
                                }
                                .background(Color.accentColor.opacity(0.2))
                                .cornerRadius(16)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .frame(minWidth: 500, minHeight: 400)
    }
    
    private func saveTask() {
        let finalDueDate = hasDueDate ? dueDate : nil
        
        let task = Task(
            id: existingTask?.id ?? UUID(),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            isCompleted: existingTask?.isCompleted ?? false,
            priority: priority,
            dueDate: finalDueDate,
            tags: tags,
            creationDate: existingTask?.creationDate ?? Date(),
            completionDate: existingTask?.completionDate
        )
        
        presentationMode.wrappedValue.dismiss()
        onSave(task)
    }
    
    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
            tags.append(trimmedTag)
            newTag = ""
        }
    }
    
    private func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }
}

// 流式布局视图
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let width = proposal.width ?? .infinity
        var height: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        for view in subviews {
            let viewSize = view.sizeThatFits(.unspecified)
            if x + viewSize.width > width {
                y += maxHeight + spacing
                x = 0
                maxHeight = 0
            }
            
            maxHeight = max(maxHeight, viewSize.height)
            x += viewSize.width + spacing
        }
        
        height = y + maxHeight
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        var x = bounds.minX
        var y = bounds.minY
        var maxHeight: CGFloat = 0
        
        for view in subviews {
            let viewSize = view.sizeThatFits(.unspecified)
            
            if x + viewSize.width > bounds.width {
                y += maxHeight + spacing
                x = bounds.minX
                maxHeight = 0
            }
            
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(width: viewSize.width, height: viewSize.height))
            
            maxHeight = max(maxHeight, viewSize.height)
            x += viewSize.width + spacing
        }
    }
}
