//
//  ContentView.swift
//  HaengdongHago
//
//  Created by bonhyuk on 3/24/26.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(Router.self) var router

    var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            // 할일
            NavigationStack {
                TodoListView()
            }
            .tabItem {
                Label("할일", systemImage: "checklist")
            }
            .tag(Router.Tab.todo)

            // 메시지
            NavigationStack {
                MessageListView()
            }
            .tabItem {
                Label("메시지", systemImage: "message")
            }
            .tag(Router.Tab.message)
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: ActionMessageEntity.self, NotificationSettingEntity.self, TodoEntity.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let context = container.mainContext

    ContentView()
        .environment(Router())
        .environment(PreviewSupport.messageListViewModel(context))
        .environment(PreviewSupport.notificationSettingViewModel(context))
        .environment(PreviewSupport.todoListViewModel(context))
        .modelContainer(container)
}
