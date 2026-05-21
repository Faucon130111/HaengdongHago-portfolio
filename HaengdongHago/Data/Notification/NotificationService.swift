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
    case scheduleFailed(Error)
}

final class NotificationService: NotificationServiceProtocol {
    private static let idPrefix = "motivation-"
    private static let referenceDateKey = "motivationReferenceDate"

    // MARK: - 기준일 초기화 (앱 최초 실행 시 1회)

    func initializeReferenceData() {
        if UserDefaults.standard.object(forKey: Self.referenceDateKey) == nil {
            UserDefaults.standard.set(Date(), forKey: Self.referenceDateKey)
        }
    }

    // MARK: - 권한 요청

    func requestPermission() async throws {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])

        if !granted {
            throw NotificationError.permissionDenied
        }
    }

    // MARK: - 30일치 알림 등록

    func reschedule(messages: [ActionMessage], setting: NotificationSetting) async {
        guard !messages.isEmpty else {
            cancelMotivationNotifications()
            print("📵 [Notification] 메시지 없음 → 알림 전체 취소")
            return
        }

        let center = UNUserNotificationCenter.current()
        let sorted = messages.sorted { $0.order < $1.order }
        let isSequential = setting.deliveryMode == .sequential

        cancelMotivationNotifications()
        print("🔄 [Notification] reschedule 시작 — 메시지 \(messages.count)개, 모드: \(isSequential ? "순차" : "랜덤")")

        for dayOffset in 0 ..< 30 {
            let message = isSequential
                ? sequentialMessage(for: dayOffset, messages: sorted)
                : randomMessage(for: dayOffset, messages: sorted)

            var dateComponents = DateComponents()
            let targetDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: .now)!

            dateComponents.hour = setting.hour
            dateComponents.minute = setting.minute
            dateComponents.day = Calendar.current.component(.day, from: targetDate)
            dateComponents.month = Calendar.current.component(.month, from: targetDate)
            dateComponents.year = Calendar.current.component(.year, from: targetDate)

            let content = UNMutableNotificationContent()
            content.title = "행동하고🔥"
            content.body = message.content
            content.sound = .default
            content.userInfo = ["type": "message", "id": message.id.uuidString]

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let request = UNNotificationRequest(
                identifier: "\(Self.idPrefix)\(dayOffset)",
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
            print("  [\(dayOffset)] \(dateComponents.month!)/\(dateComponents.day!) \(dateComponents.hour!):\(String(format: "%02d", dateComponents.minute!)) → \(message.content.prefix(20))…")
        }

        print("✅ [Notification] 등록 완료 — 30개")
    }

    // MARK: - 잔여 알림 부족 시에만 재등록

    func rescheduleIfNeeded(messages: [ActionMessage], setting: NotificationSetting) async {
        let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        let remaining = requests.count(where: { $0.identifier.hasPrefix(Self.idPrefix) })

        print("🔍 [Notification] rescheduleIfNeeded — 잔여: \(remaining)개 \(remaining < 10 ? "→ 재등록" : "→ 충분, 스킵")")

        if remaining < 10 {
            await reschedule(messages: messages, setting: setting)
        }
    }

    // MARK: - 알림 취소

    func cancelMotivationNotifications() {
        let ids = (0 ..< 30).map { "\(Self.idPrefix)\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }

    // MARK: - 디버깅용

    func pendingRequests() async -> [UNNotificationRequest] {
        await UNUserNotificationCenter.current().pendingNotificationRequests()
    }

    // MARK: - Private

    private func daysSinceReference() -> Int {
        let ref = (UserDefaults.standard.object(forKey: Self.referenceDateKey) as? Date) ?? Date()
        return Calendar.current.dateComponents([.day], from: ref, to: .now).day ?? 0
    }

    private func sequentialMessage(for dayOffset: Int, messages: [ActionMessage]) -> ActionMessage {
        let idx = (daysSinceReference() + dayOffset) % messages.count
        return messages[idx]
    }

    private func randomMessage(for dayOffset: Int, messages: [ActionMessage]) -> ActionMessage {
        let day = daysSinceReference() + dayOffset
        let weekSeed = UInt64(max(day / 7, 1))
        var rng = SeededRandomNumberGenerator(seed: weekSeed)
        let shuffled = messages.shuffled(using: &rng)
        return shuffled[day % shuffled.count]
    }
}

// MARK: - SeededRandomNumberGenerator (xorshift64)

private struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 1 : seed
    }

    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
