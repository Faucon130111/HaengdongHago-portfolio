//
//  HaengdongHagoApp.swift
//  HaengdongHago
//
//  Created by bonhyuk on 3/24/26.
//

import Combine
import SwiftData
import SwiftUI

@main
struct HaengdongHagoApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var showSplash = true
    @State private var router = Router()
    @State private var isInitialLaunch = true

    private let notificationService: NotificationService
    private let notificationDelegate: NotificationDelegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ActionMessage.self,
            NotificationSetting.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        let service = NotificationService()
        service.initializeReferenceDate()

        let delegate = NotificationDelegate(modelContext: sharedModelContainer.mainContext)
        UNUserNotificationCenter.current().delegate = delegate

        notificationService = service
        notificationDelegate = delegate
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environment(router)
                    .onReceive(
                        NotificationCenter.default.publisher(for: .notificationSettingDidChange)
                            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
                    ) { _ in
                        Task { await setupNotification() }
                    }
                    .onReceive(
                        NotificationCenter.default.publisher(for: .messageListDidChange)
                            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
                    ) { _ in
                        Task { await setupNotification() }
                    }

                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .onAppear {
                            Task {
                                try await Task.sleep(for: .seconds(1.2))

                                await MainActor.run {
                                    withAnimation(.easeInOut(duration: 0.4)) {
                                        showSplash = false
                                    }
                                }
                            }
                        }
                }
            }
            .task {
                await seedDefaultsIfNeeded()

                // [행동 메시지 알림] 권한 요청 + 최초 등록
                await setupNotification()

                notificationDelegate.router = router
            }
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // 앱 최초 실행 시에는 .task의 setupNotification이 처리하므로 스킵
                if isInitialLaunch {
                    isInitialLaunch = false
                    return
                }
                // 포그라운드 복귀 시 잔여 부족할 때만 재등록
                Task { await rescheduleIfNeeded() }
            }
        }
    }

    // MARK: - Private

    @MainActor
    private func setupNotification() async {
        print("⚙️ [App] setupNotification 호출")
        do {
            try await notificationService.requestPermission()

            let context = sharedModelContainer.mainContext
            let setting = try context.fetch(FetchDescriptor<NotificationSetting>()).first ?? NotificationSetting()
            let messages = try context.fetch(FetchDescriptor<ActionMessage>())

            print("⚙️ [App] 메시지 \(messages.count)개, 알림 시간 \(setting.hour):\(String(format: "%02d", setting.minute))")
            await notificationService.reschedule(messages: messages, setting: setting)

            try? context.save()
        } catch {
            print("⚙️ [App] setupNotification 실패: \(error)")
        }
    }

    @MainActor
    private func rescheduleIfNeeded() async {
        print("⚙️ [App] rescheduleIfNeeded 호출 (포그라운드 복귀)")
        let context = sharedModelContainer.mainContext
        guard
            let setting = try? context.fetch(FetchDescriptor<NotificationSetting>()).first,
            let messages = try? context.fetch(FetchDescriptor<ActionMessage>())
        else { return }

        await notificationService.rescheduleIfNeeded(messages: messages, setting: setting)
    }

    @MainActor
    private func seedDefaultsIfNeeded() async {
        let context = sharedModelContainer.mainContext

        let descriptor = FetchDescriptor<ActionMessage>()
        let count = (try? context.fetchCount(descriptor)) ?? 0

        guard count == 0 else {
            return
        }

        for message in ActionMessage.defaults() {
            context.insert(message)
        }

        try? context.save()
    }
}
