//
//  NotificationService.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/7/26.
//

import Foundation
import UserNotifications

enum NotificationError: Error {
    case permissionDenied
    case noMessages
    case scheduleFailed(Error)
}

final class NotificationService {
    static let messageIdentifier = "haengdong.action-message"

    // MARK: - 권한 요청

    func requestPermission() async throws {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])

        if !granted {
            throw NotificationError.permissionDenied
        }
    }

    // MARK: 다음 메시지 등록

    func scheduleNextMessage(
        setting: NotificationSetting,
        messages: [ActionMessage]
    ) async throws {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        guard let next = setting.nextMessage(from: messages)
        else {
            throw NotificationError.noMessages
        }

        let content = UNMutableNotificationContent()
        content.title = "행동하고🔥"
        content.body = next.content
        content.sound = .default
        content.userInfo = [
            "type": "message",
            "id": next.id.uuidString,
        ]

        // 매일 설정한 시간에 반복
        var dateComponents = DateComponents()
        dateComponents.hour = setting.hour
        dateComponents.minute = setting.minute

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )

        // 로컬 알림은 등록 시점에 content가 고정되므로
        // 앱 실행 시마다 같은 identifier로 덮어써서 메시지를 교체함
        // APNs 도입 시 이 로직 제거 가능
        let request = UNNotificationRequest(
            identifier: Self.messageIdentifier,
            content: content,
            trigger: trigger
        )

        do {
            let center = UNUserNotificationCenter.current()
            try await center.add(request)
        } catch {
            throw NotificationError.scheduleFailed(error)
        }
    }

    // MARK: 알림 취소

    func cancelMessageNotification() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [Self.messageIdentifier]
            )
    }

    // MARK: 디버깅용

    func pendingRequests() async -> [UNNotificationRequest] {
        await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
}
