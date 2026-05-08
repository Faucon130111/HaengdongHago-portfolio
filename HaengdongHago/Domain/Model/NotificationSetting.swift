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
    var nextSequentialOrder: Int

    init(
        hour: Int = 7,
        minute: Int = 0,
        deliveryMode: DeliveryMode = .random,
        nextSequentialOrder: Int = 0
    ) {
        self.hour = hour
        self.minute = minute
        self.deliveryMode = deliveryMode
        self.nextSequentialOrder = nextSequentialOrder
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
            let sorted = messages.sorted { $0.order < $1.order }
            let candidate = sorted.first { $0.order >= nextSequentialOrder } ?? sorted.first

            if let candidate,
               let idx = sorted.firstIndex(where: { $0.id == candidate.id }) {
                let nextIdx = (idx + 1) % sorted.count
                nextSequentialOrder = sorted[nextIdx].order
            }

            return candidate
        }
    }
}
