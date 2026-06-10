//
//  HaengdongHagoApp.swift
//  HaengdongHago
//
//  Created by bonhyuk on 3/24/26.
//

import Combine
import os
import SwiftData
import SwiftUI

@main
struct HaengdongHagoApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var showSplash = true
    @State private var router = Router()
    @State private var isInitialLaunch = true
    @State private var messageListViewModel: MessageListViewModel
    @State private var notificationSettingViewModel: NotificationSettingViewModel
    @State private var todoListViewModel: TodoListViewModel

    private let notificationDelegate: NotificationDelegate
    private let seedDefaultsUseCase: SeedDefaultsUseCase
    private let setupUseCase: SetupNotificationUseCase
    private let rescheduleIfNeededUseCase: RescheduleIfNeededUseCase

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ActionMessageEntity.self,
            NotificationSettingEntity.self,
            TodoEntity.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        let context = sharedModelContainer.mainContext

        let messageRepo = SwiftDataActionMessageRepository(context: context)
        let settingRepo = SwiftDataNotificationSettingRepository(context: context)
        let todoRepo = SwiftDataTodoRepository(context: context)
        let notificationService = NotificationService()
        let todoNotificationService = TodoNotificationService()
        let referenceDateProvider = UserDefaultsReferenceDateStore()
        let scheduler = MotivationScheduler()

        let reschedule = RescheduleNotificationsUseCase(
            messageRepo: messageRepo,
            settingRepo: settingRepo,
            notificationService: notificationService,
            referenceDateProvider: referenceDateProvider,
            scheduler: scheduler
        )

        let delegate = NotificationDelegate(
            markMessageSent: MarkMessageSentUseCase(messageRepo: messageRepo)
        )
        UNUserNotificationCenter.current().delegate = delegate

        notificationDelegate = delegate
        seedDefaultsUseCase = SeedDefaultsUseCase(messageRepo: messageRepo)
        setupUseCase = SetupNotificationUseCase(
            notificationService: notificationService,
            reschedule: reschedule
        )
        rescheduleIfNeededUseCase = RescheduleIfNeededUseCase(
            notificationService: notificationService,
            reschedule: reschedule
        )

        _messageListViewModel = State(
            wrappedValue: MessageListViewModel(
                useCase: MessageUseCase(messageRepo: messageRepo, reschedule: reschedule)
            )
        )
        _notificationSettingViewModel = State(
            wrappedValue: NotificationSettingViewModel(
                useCase: NotificationSettingUseCase(settingRepo: settingRepo, reschedule: reschedule)
            )
        )
        _todoListViewModel = State(
            wrappedValue: TodoListViewModel(
                useCase: TodoUseCase(repo: todoRepo, notification: todoNotificationService)
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environment(router)
                    .environment(messageListViewModel)
                    .environment(notificationSettingViewModel)
                    .environment(todoListViewModel)
                    .onReceive(
                        NotificationCenter.default.publisher(for: .notificationTapped)
                    ) { notification in
                        if let userInfo = notification.userInfo {
                            router.handle(userInfo: userInfo)
                        }
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
                try? seedDefaultsUseCase.execute()
                messageListViewModel.load()
                todoListViewModel.load()
                await runSetupNotification()
            }
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                if isInitialLaunch {
                    isInitialLaunch = false
                    return
                }
                Task { await runRescheduleIfNeeded() }
            }
        }
    }

    // MARK: - Private

    @MainActor
    private func runSetupNotification() async {
        do {
            try await setupUseCase.execute()
        } catch {
            Logger.app.error("setupNotification 실패: \(error.localizedDescription)")
        }
    }

    @MainActor
    private func runRescheduleIfNeeded() async {
        try? await rescheduleIfNeededUseCase.execute()
    }
}
