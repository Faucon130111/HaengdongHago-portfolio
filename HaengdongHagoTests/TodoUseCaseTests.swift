//
//  TodoUseCaseTests.swift
//  HaengdongHagoTests
//
//  Created by bonhyuk on 6/10/26.
//

import Foundation
import Testing

@testable import HaengdongHago

struct TodoUseCaseTests {
    // MARK: - Helpers

    private func makeUseCase(
        repo: FakeTodoRepository,
        notification: SpyTodoNotificationService = SpyTodoNotificationService()
    ) -> TodoUseCase {
        TodoUseCase(repo: repo, notification: notification)
    }

    private let future = Date().addingTimeInterval(60 * 60)
    private let past = Date().addingTimeInterval(-60 * 60)

    // MARK: - Tests

    @Test("add는 할 일을 저장한다")
    func addStoresTodo() async throws {
        let repo = FakeTodoRepository()
        let useCase = makeUseCase(repo: repo)

        try await useCase.add(title: "운동", detail: "30분", dueDate: nil, notifies: false)

        let all = try repo.fetchAll()
        #expect(all.count == 1)
        #expect(all.first?.title == "운동")
        #expect(all.first?.detail == "30분")
    }

    @Test("알림 ON + 미래 일시면 알림을 등록한다")
    func addSchedulesWhenNotifyingFuture() async throws {
        let repo = FakeTodoRepository()
        let spy = SpyTodoNotificationService()
        let useCase = makeUseCase(repo: repo, notification: spy)

        try await useCase.add(title: "회의", detail: "", dueDate: future, notifies: true)

        #expect(spy.scheduleCallCount == 1)
    }

    @Test("알림 OFF면 알림을 등록하지 않는다")
    func addDoesNotScheduleWhenNotifyOff() async throws {
        let repo = FakeTodoRepository()
        let spy = SpyTodoNotificationService()
        let useCase = makeUseCase(repo: repo, notification: spy)

        try await useCase.add(title: "독서", detail: "", dueDate: nil, notifies: false)

        #expect(spy.scheduleCallCount == 0)
    }

    @Test("과거 일시면 알림을 등록하지 않는다")
    func addDoesNotScheduleForPastDate() async throws {
        let repo = FakeTodoRepository()
        let spy = SpyTodoNotificationService()
        let useCase = makeUseCase(repo: repo, notification: spy)

        try await useCase.add(title: "지난 일정", detail: "", dueDate: past, notifies: true)

        #expect(spy.scheduleCallCount == 0)
    }

    @Test("완료 처리하면 알림을 취소하고 다시 등록하지 않는다")
    func toggleDoneCancelsNotification() async throws {
        let todo = Todo(title: "마감 작업", dueDate: future, notifies: true)
        let repo = FakeTodoRepository([todo])
        let spy = SpyTodoNotificationService()
        let useCase = makeUseCase(repo: repo, notification: spy)

        try await useCase.toggleDone(todo)

        #expect(try repo.fetchAll().first?.isDone == true)
        #expect(spy.scheduleCallCount == 0)
        #expect(spy.canceledIds.contains(todo.id))
    }

    @Test("update로 알림을 끄면 기존 알림을 취소한다")
    func updateTurningOffNotificationCancels() async throws {
        let todo = Todo(title: "원래 알림 있음", dueDate: future, notifies: true)
        let repo = FakeTodoRepository([todo])
        let spy = SpyTodoNotificationService()
        let useCase = makeUseCase(repo: repo, notification: spy)

        try await useCase.update(todo, title: "알림 끔", detail: "", dueDate: nil, notifies: false)

        #expect(spy.scheduleCallCount == 0)
        #expect(spy.canceledIds.contains(todo.id))
        #expect(try repo.fetchAll().first?.notifies == false)
    }

    @Test("delete는 할 일을 제거하고 알림을 취소한다")
    func deleteRemovesAndCancels() async throws {
        let todo = Todo(title: "삭제 대상", dueDate: future, notifies: true)
        let repo = FakeTodoRepository([todo])
        let spy = SpyTodoNotificationService()
        let useCase = makeUseCase(repo: repo, notification: spy)

        try await useCase.delete(todo)

        #expect(try repo.fetchAll().isEmpty)
        #expect(spy.canceledIds.contains(todo.id))
    }
}
