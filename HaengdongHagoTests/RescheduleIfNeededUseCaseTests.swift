//
//  RescheduleIfNeededUseCaseTests.swift
//  HaengdongHagoTests
//
//  Created by bonhyuk on 5/21/26.
//

import Foundation
import Testing

@testable import HaengdongHago

struct RescheduleIfNeededUseCaseTests {
    private func makeUseCase(
        service: SpyNotificationService,
        threshold: Int
    ) -> RescheduleIfNeededUseCase {
        let reschedule = RescheduleNotificationsUseCase(
            messageRepo: FakeActionMessageRepository([ActionMessage(content: "a", order: 0)]),
            settingRepo: FakeNotificationSettingRepository(),
            notificationService: service,
            referenceDateProvider: FixedReferenceDateProvider(date: Date()),
            scheduler: MotivationScheduler()
        )
        return RescheduleIfNeededUseCase(
            notificationService: service,
            reschedule: reschedule,
            threshold: threshold
        )
    }

    @Test("잔여 알림이 임계값 미만이면 재등록한다")
    func reschedulesWhenBelowThreshold() async throws {
        let service = SpyNotificationService()
        service.pendingCount = 5
        let useCase = makeUseCase(service: service, threshold: 10)

        try await useCase.execute()

        #expect(service.scheduleCallCount == 1)
    }

    @Test("잔여 알림이 임계값과 같으면 재등록하지 않는다")
    func skipsWhenAtThreshold() async throws {
        let service = SpyNotificationService()
        service.pendingCount = 10
        let useCase = makeUseCase(service: service, threshold: 10)

        try await useCase.execute()

        #expect(service.scheduleCallCount == 0)
    }

    @Test("잔여 알림이 임계값을 초과하면 재등록하지 않는다")
    func skipsWhenAboveThreshold() async throws {
        let service = SpyNotificationService()
        service.pendingCount = 25
        let useCase = makeUseCase(service: service, threshold: 10)

        try await useCase.execute()

        #expect(service.scheduleCallCount == 0)
    }
}
