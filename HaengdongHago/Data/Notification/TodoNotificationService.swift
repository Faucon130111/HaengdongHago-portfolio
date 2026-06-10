//
//  TodoNotificationService.swift
//  HaengdongHago
//
//  Created by bonhyuk on 6/10/26.
//

import Foundation
import os
import UserNotifications

final class TodoNotificationService: TodoNotificationScheduling {
    private static let idPrefix = "todo-"
    private let center = UNUserNotificationCenter.current()

    // MARK: - 단건 알림 등록 (같은 id는 교체)

    func schedule(id: UUID, title: String, body: String, at fireDate: Date) async {
        let identifier = Self.identifier(for: id)
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.userInfo = ["type": "todo", "id": id.uuidString]

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: fireDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
            Logger.notification.debug("할 일 알림 등록 — \(identifier)")
        } catch {
            Logger.notification.error("할 일 알림 등록 실패: \(error.localizedDescription)")
        }
    }

    // MARK: - 단건 알림 취소

    func cancel(id: UUID) async {
        center.removePendingNotificationRequests(withIdentifiers: [Self.identifier(for: id)])
    }

    // MARK: - Private

    private static func identifier(for id: UUID) -> String {
        "\(idPrefix)\(id.uuidString)"
    }
}
