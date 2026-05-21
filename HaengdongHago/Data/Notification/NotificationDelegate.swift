//
//  NotificationDelegate.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/7/26.
//

import Foundation
import UserNotifications

extension Notification.Name {
    static let notificationTapped = Notification.Name("com.haengdongha.notificationTapped")
}

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    private let messageRepo: ActionMessageRepository

    init(messageRepo: ActionMessageRepository) {
        self.messageRepo = messageRepo
    }

    // MARK: 앱 켜진 상태에서 알림 수신 시 배너 표시

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        print("🔔 [Delegate] 포그라운드 알림 수신: \(notification.request.identifier) — \(notification.request.content.body.prefix(30))")
        return [.banner, .sound]
    }

    // MARK: 알림 탭 콜백

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        print("👆 [Delegate] 알림 탭: \(response.notification.request.identifier)")

        await MainActor.run {
            NotificationCenter.default.post(
                name: .notificationTapped,
                object: nil,
                userInfo: userInfo
            )

            guard
                let type = userInfo["type"] as? String, type == "message",
                let idString = userInfo["id"] as? String,
                let id = UUID(uuidString: idString)
            else {
                print("👆 [Delegate] userInfo 파싱 실패: \(userInfo)")
                return
            }

            print("👆 [Delegate] lastSentAt 업데이트 → messageId: \(idString)")

            try? messageRepo.updateLastSentAt(messageId: id, date: Date())
            try? messageRepo.save()
        }
    }
}
