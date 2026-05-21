//
//  MotivationSchedulerTests.swift
//  HaengdongHagoTests
//
//  Created by bonhyuk on 5/21/26.
//

import Foundation
import Testing

@testable import HaengdongHago

struct MotivationSchedulerTests {
    private let calendar = Calendar(identifier: .gregorian)

    // MARK: - Helpers

    private func date(_ year: Int, _ month: Int, _ day: Int, _ hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    private func messages(_ contents: [String]) -> [ActionMessage] {
        contents.enumerated().map { ActionMessage(content: $0.element, order: $0.offset) }
    }

    // MARK: - Tests

    @Test("메시지가 없으면 빈 계획을 반환한다")
    func emptyMessages() {
        let scheduler = MotivationScheduler(daysAhead: 30, calendar: calendar)
        let plans = scheduler.plan(
            messages: [],
            setting: NotificationSetting(),
            referenceDate: date(2026, 5, 21),
            now: date(2026, 5, 21)
        )

        #expect(plans.isEmpty)
    }

    @Test("daysAhead 만큼의 알림을 0부터 순서대로 생성한다")
    func planCountAndOffsets() {
        let scheduler = MotivationScheduler(daysAhead: 7, calendar: calendar)
        let plans = scheduler.plan(
            messages: messages(["a", "b"]),
            setting: NotificationSetting(),
            referenceDate: date(2026, 5, 21),
            now: date(2026, 5, 21)
        )

        #expect(plans.count == 7)
        #expect(plans.map(\.dayOffset) == Array(0 ..< 7))
    }

    @Test("발송 시각은 설정의 시/분을, 날짜는 오늘부터 하루씩 증가한다")
    func fireDates() {
        let scheduler = MotivationScheduler(daysAhead: 3, calendar: calendar)
        let setting = NotificationSetting(hour: 9, minute: 30, deliveryMode: .sequential)
        let now = date(2026, 5, 21)

        let plans = scheduler.plan(
            messages: messages(["a", "b", "c"]),
            setting: setting,
            referenceDate: now,
            now: now
        )

        #expect(plans[0].fireDate.hour == 9)
        #expect(plans[0].fireDate.minute == 30)
        #expect(plans[0].fireDate.day == 21)
        #expect(plans[1].fireDate.day == 22)
        #expect(plans[2].fireDate.day == 23)
    }

    @Test("순차 모드는 입력 순서와 무관하게 order 순서대로 배정한다")
    func sequentialUsesOrder() {
        let scheduler = MotivationScheduler(daysAhead: 4, calendar: calendar)
        let unsorted = [
            ActionMessage(content: "two", order: 2),
            ActionMessage(content: "zero", order: 0),
            ActionMessage(content: "one", order: 1),
        ]
        let now = date(2026, 5, 21)

        let plans = scheduler.plan(
            messages: unsorted,
            setting: NotificationSetting(deliveryMode: .sequential),
            referenceDate: now,
            now: now
        )

        #expect(plans.map(\.message.content) == ["zero", "one", "two", "zero"])
    }

    @Test("순차 모드는 기준일로부터 지난 일수만큼 시작 위치가 밀린다")
    func sequentialShiftsByReference() {
        let scheduler = MotivationScheduler(daysAhead: 3, calendar: calendar)
        let reference = date(2026, 5, 19) // now보다 2일 전
        let now = date(2026, 5, 21)

        let plans = scheduler.plan(
            messages: messages(["a", "b", "c"]),
            setting: NotificationSetting(deliveryMode: .sequential),
            referenceDate: reference,
            now: now
        )

        // daysSinceReference == 2 → 시작 인덱스 2부터 순환
        #expect(plans.map(\.message.content) == ["c", "a", "b"])
    }

    @Test("랜덤 모드는 동일 입력에 대해 동일한 결과를 낸다 (결정적)")
    func randomIsDeterministic() {
        let scheduler = MotivationScheduler(daysAhead: 14, calendar: calendar)
        let msgs = messages(["a", "b", "c", "d"])
        let reference = date(2026, 5, 1)
        let now = date(2026, 5, 21)

        let first = scheduler.plan(
            messages: msgs,
            setting: NotificationSetting(deliveryMode: .random),
            referenceDate: reference,
            now: now
        )
        let second = scheduler.plan(
            messages: msgs,
            setting: NotificationSetting(deliveryMode: .random),
            referenceDate: reference,
            now: now
        )

        #expect(first.map(\.message.content) == second.map(\.message.content))
    }

    @Test("랜덤 모드도 항상 유효한 메시지만 배정한다")
    func randomAssignsValidMessages() {
        let scheduler = MotivationScheduler(daysAhead: 30, calendar: calendar)
        let contents = ["a", "b", "c", "d"]

        let plans = scheduler.plan(
            messages: messages(contents),
            setting: NotificationSetting(deliveryMode: .random),
            referenceDate: date(2026, 5, 1),
            now: date(2026, 5, 21)
        )

        #expect(plans.count == 30)
        #expect(plans.allSatisfy { contents.contains($0.message.content) })
    }
}
