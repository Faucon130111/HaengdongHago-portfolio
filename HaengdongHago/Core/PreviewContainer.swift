//
//  PreviewContainer.swift
//  HaengdongHago
//
//  Created by bonhyuk on 4/3/26.
//

import SwiftData

@MainActor
struct PreviewContainer {
    static let actionMessage: ModelContainer = {
        do {
            let container = try ModelContainer(
                for: ActionMessageEntity.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )

            let context = container.mainContext
            for item in ActionMessage.defaults() {
                context.insert(ActionMessageEntity.from(item))
            }

            return container
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }()
}

// MARK: - Preview ViewModel 조립

@MainActor
enum PreviewSupport {
    static func messageListViewModel(_ context: ModelContext) -> MessageListViewModel {
        let repo = SwiftDataActionMessageRepository(context: context)
        return MessageListViewModel(
            useCase: MessageUseCase(messageRepo: repo, reschedule: reschedule(context))
        )
    }

    static func notificationSettingViewModel(_ context: ModelContext) -> NotificationSettingViewModel {
        let repo = SwiftDataNotificationSettingRepository(context: context)
        return NotificationSettingViewModel(
            useCase: NotificationSettingUseCase(settingRepo: repo, reschedule: reschedule(context))
        )
    }

    private static func reschedule(_ context: ModelContext) -> RescheduleNotificationsUseCase {
        RescheduleNotificationsUseCase(
            messageRepo: SwiftDataActionMessageRepository(context: context),
            settingRepo: SwiftDataNotificationSettingRepository(context: context),
            notificationService: NotificationService(),
            referenceDateProvider: UserDefaultsReferenceDateStore(),
            scheduler: MotivationScheduler()
        )
    }
}
