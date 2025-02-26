import SwiftUI

@main
struct MacTodoApp: App {
    @StateObject private var todoManager = TodoManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(todoManager)
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("新建任务") {
                    todoManager.showNewTaskView = true
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            
            CommandMenu("任务") {
                Button("完成选中的任务") {
                    todoManager.completeSelectedTasks()
                }
                .keyboardShortcut("d", modifiers: .command)
                
                Button("删除选中的任务") {
                    todoManager.deleteSelectedTasks()
                }
                .keyboardShortcut(.delete, modifiers: .command)
                
                Divider()
                
                Button("全部标记为已完成") {
                    todoManager.completeAllTasks()
                }
                .keyboardShortcut("a", modifiers: [.command, .shift])
            }
        }
    }
}
