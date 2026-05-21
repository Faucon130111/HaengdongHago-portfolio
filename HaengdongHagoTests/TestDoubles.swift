//
//  TestDoubles.swift
//  HaengdongHagoTests
//
//  Created by bonhyuk on 5/21/26.
//

import Foundation

@testable import HaengdongHago

// MARK: - 인메모리 메시지 저장소

final class FakeActionMessageRepository: ActionMessageRepository {
    var messages: [ActionMessage]

    init(_ messages: [ActionMessage] = []) {
        self.messages = messages
    }

    func fetchAll() throws -> [ActionMessage] {
        messages.sorted { $0.order < $1.order }
    }

    func fetchCount() throws -> Int {
        messages.count
    }

    func add(_ message: ActionMessage) throws {
        messages.append(message)
    }

    func update(_ message: ActionMessage) throws {
        guard let idx = messages.firstIndex(where: { $0.id == message.id }) else { return }
        messages[idx] = message
    }

    func delete(_ message: ActionMessage) throws {
        messages.removeAll { $0.id == message.id }
    }

    func updateLastSentAt(messageId: UUID, date: Date) throws {
        guard let idx = messages.firstIndex(where: { $0.id == messageId }) else { return }
        messages[idx].lastSentAt = date
    }
}

// MARK: - 인메모리 알림 설정 저장소

final class FakeNotificationSettingRepository: NotificationSettingRepository {
    var setting: NotificationSetting

    init(_ setting: NotificationSetting = NotificationSetting()) {
        self.setting = setting
    }

    func fetch() throws -> NotificationSetting {
        setting
    }

    func update(_ setting: NotificationSetting) throws {
        self.setting = setting
    }
}

// MARK: - 알림 서비스 스파이 (호출 기록)

final class SpyNotificationService: NotificationServiceProtocol {
    private(set) var requestPermissionCallCount = 0
    private(set) var scheduleCallCount = 0
    private(set) var lastPlans: [PlannedNotification] = []
    var pendingCount = 0

    func requestPermission() async throws {
        requestPermissionCallCount += 1
    }

    func schedule(_ plans: [PlannedNotification]) async {
        scheduleCallCount += 1
        lastPlans = plans
    }

    func pendingMotivationCount() async -> Int {
        pendingCount
    }
}

// MARK: - 고정 기준일 제공자

struct FixedReferenceDateProvider: ReferenceDateProviding {
    let date: Date

    func referenceDate() -> Date {
        date
    }
}
