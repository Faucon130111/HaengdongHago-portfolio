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
            // 오늘
            Text("오늘 화면")
                .tabItem {
                    Label("오늘", systemImage: "list.bullet")
                }
                .tag(Router.Tab.today)

            // 전체
            Text("전체 화면")
                .tabItem {
                    Label("전체", systemImage: "calendar")
                }
                .tag(Router.Tab.all)

            // 메시지
            NavigationStack {
                MessageListView()
            }
            .tabItem {
                Label("메시지", systemImage: "message")
            }
            .tag(Router.Tab.message)

            // 더보기
            Text("더보기 화면")
                .tabItem {
                    Label("더보기", systemImage: "ellipsis.circle")
                }
                .tag(Router.Tab.more)
        }
    }
}

#Preview {
    let container = try! ModelContainer(
        for: ActionMessageEntity.self, NotificationSettingEntity.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    ContentView()
        .environment(Router())
        .modelContainer(container)
}
