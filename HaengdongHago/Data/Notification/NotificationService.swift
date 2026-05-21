//
//  NotificationService.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/7/26.
//

import Foundation
import os
import UserNotifications

enum NotificationError: Error {
    case permissionDenied
}

final class NotificationService: NotificationServiceProtocol {
    private static let idPrefix = "motivation-"
    private let center = UNUserNotificationCenter.current()

    // MARK: - 권한 요청

    func requestPermission() async throws {
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
        if !granted {
            throw NotificationError.permissionDenied
        }
    }

    // MARK: - 계획된 알림 등록 (기존 동기부여 알림은 모두 교체)

    func schedule(_ plans: [PlannedNotification]) async {
        await cancelMotivationNotifications()

        guard !plans.isEmpty else {
            Logger.notification.debug("등록할 메시지 없음 → 알림 전체 취소")
            return
        }

        for plan in plans {
            let content = UNMutableNotificationContent()
            content.title = "행동하고🔥"
            content.body = plan.message.content
            content.sound = .default
            content.userInfo = ["type": "message", "id": plan.message.id.uuidString]

            let trigger = UNCalendarNotificationTrigger(dateMatching: plan.fireDate, repeats: false)
            let request = UNNotificationRequest(
                identifier: "\(Self.idPrefix)\(plan.dayOffset)",
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }

        Logger.notification.debug("알림 등록 완료 — \(plans.count)개")
    }

    // MARK: - 잔여 동기부여 알림 수

    func pendingMotivationCount() async -> Int {
        let requests = await center.pendingNotificationRequests()
        return requests.count { $0.identifier.hasPrefix(Self.idPrefix) }
    }

    // MARK: - Private

    private func cancelMotivationNotifications() async {
        let pending = await center.pendingNotificationRequests()
        let ids = pending.map(\.identifier).filter { $0.hasPrefix(Self.idPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }
}
