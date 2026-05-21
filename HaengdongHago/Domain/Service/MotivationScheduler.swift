//
//  MotivationScheduler.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/21/26.
//

import Foundation

// MARK: - 등록 예정 알림 (Domain이 계산한 결과)

struct PlannedNotification {
    let dayOffset: Int
    let fireDate: DateComponents
    let message: ActionMessage
}

// MARK: - 메시지 선택 정책

struct MotivationScheduler {
    let daysAhead: Int
    private let calendar: Calendar

    init(daysAhead: Int = 30, calendar: Calendar = .current) {
        self.daysAhead = daysAhead
        self.calendar = calendar
    }

    func plan(
        messages: [ActionMessage],
        setting: NotificationSetting,
        referenceDate: Date,
        now: Date = .now
    ) -> [PlannedNotification] {
        guard !messages.isEmpty else { return [] }

        let sorted = messages.sorted { $0.order < $1.order }
        let daysSinceReference = calendar.dateComponents(
            [.day],
            from: referenceDate,
            to: now
        ).day ?? 0
        let isSequential = setting.deliveryMode == .sequential

        return (0 ..< daysAhead).map { dayOffset in
            let dayIndex = daysSinceReference + dayOffset
            let message = isSequential
                ? sequentialMessage(dayIndex: dayIndex, messages: sorted)
                : randomMessage(dayIndex: dayIndex, messages: sorted)

            let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: now)!
            var fireDate = calendar.dateComponents([.year, .month, .day], from: targetDate)
            fireDate.hour = setting.hour
            fireDate.minute = setting.minute

            return PlannedNotification(
                dayOffset: dayOffset,
                fireDate: fireDate,
                message: message
            )
        }
    }

    // MARK: - Private

    private func sequentialMessage(dayIndex: Int, messages: [ActionMessage]) -> ActionMessage {
        messages[dayIndex % messages.count]
    }

    private func randomMessage(dayIndex: Int, messages: [ActionMessage]) -> ActionMessage {
        let weekSeed = UInt64(max(dayIndex / 7, 1))
        var rng = SeededRandomNumberGenerator(seed: weekSeed)
        let shuffled = messages.shuffled(using: &rng)
        return shuffled[dayIndex % shuffled.count]
    }
}

// MARK: - SeededRandomNumberGenerator (xorshift64)

struct SeededRandomNumberGenerator: RandomNumberGenerator {
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
