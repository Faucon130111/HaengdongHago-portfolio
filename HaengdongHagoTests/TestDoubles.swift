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

// MARK: - 인메모리 할 일 저장소

final class FakeTodoRepository: TodoRepository {
    var todos: [Todo]

    init(_ todos: [Todo] = []) {
        self.todos = todos
    }

    func fetchAll() throws -> [Todo] {
        todos
    }

    func add(_ todo: Todo) throws {
        todos.append(todo)
    }

    func update(_ todo: Todo) throws {
        guard let idx = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        todos[idx] = todo
    }

    func delete(_ todo: Todo) throws {
        todos.removeAll { $0.id == todo.id }
    }
}

// MARK: - 할 일 알림 스파이 (호출 기록)

final class SpyTodoNotificationService: TodoNotificationScheduling {
    private(set) var scheduleCallCount = 0
    private(set) var cancelCallCount = 0
    private(set) var scheduledIds: [UUID] = []
    private(set) var canceledIds: [UUID] = []
    private(set) var lastScheduledDate: Date?

    func schedule(id: UUID, title: String, body: String, at fireDate: Date) async {
        scheduleCallCount += 1
        scheduledIds.append(id)
        lastScheduledDate = fireDate
    }

    func cancel(id: UUID) async {
        cancelCallCount += 1
        canceledIds.append(id)
    }
}
