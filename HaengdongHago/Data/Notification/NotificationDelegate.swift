//
//  NotificationDelegate.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/7/26.
//

import Foundation
import SwiftData
import UserNotifications

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    private let notificationService: NotificationService
    private let modelContext: ModelContext
    var router: Router?

    init(
        notificationService: NotificationService,
        modelContext: ModelContext
    ) {
        self.notificationService = notificationService
        self.modelContext = modelContext
    }

    // MARK: 앱 켜진 상태에서 알림 수신 시 배너 표시

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent _: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    // MARK: 알림 탭 콜백

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo

        await MainActor.run {
            router?.handle(userInfo: userInfo)

            guard
                let type = userInfo["type"] as? String, type == "message",
                let idString = userInfo["id"] as? String,
                let id = UUID(uuidString: idString)
            else {
                return
            }

            updateLastSentAt(messageId: id)
            reschedule()
        }
    }

    // MARK: - Private

    private func updateLastSentAt(messageId: UUID) {
        let descriptor = FetchDescriptor<ActionMessage>(
            predicate: #Predicate { $0.id == messageId }
        )

        guard let message = try? modelContext.fetch(descriptor).first
        else {
            return
        }

        message.lastSentAt = Date()
        try? modelContext.save()
    }

    private func reschedule() {
        let settingDescriptor = FetchDescriptor<NotificationSetting>()
        let messageDescriptor = FetchDescriptor<ActionMessage>()

        guard
            let setting = try? modelContext.fetch(settingDescriptor).first,
            let messages = try? modelContext.fetch(messageDescriptor)
        else {
            return
        }

        Task {
            try? await notificationService.scheduleNextMessage(
                setting: setting,
                messages: messages
            )
        }
    }
}
