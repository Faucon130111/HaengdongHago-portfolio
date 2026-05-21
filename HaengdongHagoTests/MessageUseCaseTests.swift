//
//  MessageUseCaseTests.swift
//  HaengdongHagoTests
//
//  Created by bonhyuk on 5/21/26.
//

import Foundation
import Testing

@testable import HaengdongHago

struct MessageUseCaseTests {
    // MARK: - Helpers

    private func makeReschedule(
        repo: ActionMessageRepository,
        service: NotificationServiceProtocol
    ) -> RescheduleNotificationsUseCase {
        RescheduleNotificationsUseCase(
            messageRepo: repo,
            settingRepo: FakeNotificationSettingRepository(),
            notificationService: service,
            referenceDateProvider: FixedReferenceDateProvider(date: Date()),
            scheduler: MotivationScheduler()
        )
    }

    private func makeUseCase(
        repo: FakeActionMessageRepository,
        service: SpyNotificationService = SpyNotificationService()
    ) -> MessageUseCase {
        MessageUseCase(messageRepo: repo, reschedule: makeReschedule(repo: repo, service: service))
    }

    // MARK: - Tests

    @Test("빈 저장소에 add하면 order 0으로 저장한다")
    func addToEmptyStore() async throws {
        let repo = FakeActionMessageRepository()
        let useCase = makeUseCase(repo: repo)

        try await useCase.add(content: "hello")

        let all = try repo.fetchAll()
        #expect(all.count == 1)
        #expect(all.first?.content == "hello")
        #expect(all.first?.order == 0)
    }

    @Test("add는 마지막 order + 1로 저장하고 재스케줄을 트리거한다")
    func addAppendsAndReschedules() async throws {
        let repo = FakeActionMessageRepository([
            ActionMessage(content: "first", order: 0),
            ActionMessage(content: "second", order: 1),
        ])
        let service = SpyNotificationService()
        let useCase = makeUseCase(repo: repo, service: service)

        try await useCase.add(content: "third")

        let all = try repo.fetchAll()
        #expect(all.count == 3)
        #expect(all.last?.content == "third")
        #expect(all.last?.order == 2)
        #expect(service.scheduleCallCount == 1)
    }

    @Test("update는 내용을 변경하고 재스케줄을 트리거한다")
    func updateChangesContent() async throws {
        let original = ActionMessage(content: "old", order: 0)
        let repo = FakeActionMessageRepository([original])
        let service = SpyNotificationService()
        let useCase = makeUseCase(repo: repo, service: service)

        try await useCase.update(original, content: "new")

        #expect(try repo.fetchAll().first?.content == "new")
        #expect(service.scheduleCallCount == 1)
    }

    @Test("delete는 메시지를 제거하고 재스케줄을 트리거한다")
    func deleteRemovesMessage() async throws {
        let target = ActionMessage(content: "bye", order: 0)
        let repo = FakeActionMessageRepository([target])
        let service = SpyNotificationService()
        let useCase = makeUseCase(repo: repo, service: service)

        try await useCase.delete(target)

        #expect(try repo.fetchAll().isEmpty)
        #expect(service.scheduleCallCount == 1)
    }

    @Test("재스케줄 시 현재 메시지들이 알림 서비스로 전달된다")
    func reschedulePassesCurrentMessages() async throws {
        let repo = FakeActionMessageRepository()
        let service = SpyNotificationService()
        let useCase = makeUseCase(repo: repo, service: service)

        try await useCase.add(content: "only one")

        // add 직후 재스케줄 → 방금 추가한 메시지가 계획에 반영되어야 함
        #expect(!service.lastPlans.isEmpty)
        #expect(service.lastPlans.allSatisfy { $0.message.content == "only one" })
    }
}
