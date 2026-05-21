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
    @State private var messageListViewModel: MessageListViewModel
    @State private var notificationSettingViewModel: NotificationSettingViewModel

    private let notificationService: NotificationServiceProtocol
    private let notificationDelegate: NotificationDelegate
    private let messageRepo: ActionMessageRepository
    private let settingRepo: NotificationSettingRepository

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ActionMessageEntity.self,
            NotificationSettingEntity.self,
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

        let service = NotificationService()
        service.initializeReferenceData()

        let mRepo = SwiftDataActionMessageRepository(context: context)
        let sRepo = SwiftDataNotificationSettingRepository(context: context)

        let delegate = NotificationDelegate(messageRepo: mRepo)
        UNUserNotificationCenter.current().delegate = delegate

        notificationService = service
        notificationDelegate = delegate
        messageRepo = mRepo
        settingRepo = sRepo
        _messageListViewModel = State(wrappedValue: MessageListViewModel(messageRepo: mRepo))
        _notificationSettingViewModel = State(wrappedValue: NotificationSettingViewModel(settingRepo: sRepo))
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environment(router)
                    .environment(messageListViewModel)
                    .environment(notificationSettingViewModel)
                    .onReceive(
                        NotificationCenter.default.publisher(for: .notificationSettingDidChange)
                            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
                    ) { _ in
                        Task { await runSetupNotification() }
                    }
                    .onReceive(
                        NotificationCenter.default.publisher(for: .messageListDidChange)
                            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
                    ) { _ in
                        Task { await runSetupNotification() }
                    }
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
                try? SeedDefaultsUseCase(messageRepo: messageRepo).execute()
                messageListViewModel.load()
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
        print("⚙️ [App] setupNotification 호출")
        do {
            try await SetupNotificationUseCase(
                notificationService: notificationService,
                messageRepo: messageRepo,
                settingRepo: settingRepo
            ).execute()
        } catch {
            print("⚙️ [App] setupNotification 실패: \(error)")
        }
    }

    @MainActor
    private func runRescheduleIfNeeded() async {
        print("⚙️ [App] rescheduleIfNeeded 호출 (포그라운드 복귀)")
        try? await RescheduleIfNeededUseCase(
            notificationService: notificationService,
            messageRepo: messageRepo,
            settingRepo: settingRepo
        ).execute()
    }
}
