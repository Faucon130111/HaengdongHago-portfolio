//
//  NotificationSetting.swift
//  HaengdongHago
//
//  Created by bonhyuk on 4/24/26.
//

import Foundation
import SwiftData

// MARK: - 알림 설정

@Model
class NotificationSetting {
    var hour: Int
    var minute: Int
    var deliveryMode: DeliveryMode

    init(
        hour: Int = 7,
        minute: Int = 0,
        deliveryMode: DeliveryMode = .random
    ) {
        self.hour = hour
        self.minute = minute
        self.deliveryMode = deliveryMode
    }
}

extension NotificationSetting {
    func nextMessage(from messages: [ActionMessage]) -> ActionMessage? {
        guard !messages.isEmpty
        else {
            return nil
        }

        switch deliveryMode {
        case .random:
            // 아직 안 보낸 것 우선, 없으면 전체에서 랜덤
            let unsent = messages.filter { $0.lastSentAt == nil }
            return unsent.randomElement() ?? messages.randomElement()

        case .sequential:
            // order 오름차순 정렬 후 가장 오래된 것 또는 미발송
            let sorted = messages.sorted { $0.order < $1.order }
            if let unsent = sorted.first(where: { $0.lastSentAt == nil }) {
                return unsent
            }

            // 전부 발송된 경우 -> 가장 오래전에 발송된 것
            return sorted.min { lhs, rhs in
                (lhs.lastSentAt ?? .distantPast) < (rhs.lastSentAt ?? .distantPast)
            }
        }
    }
}
