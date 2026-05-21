//
//  NotificationSetting.swift
//  HaengdongHago
//
//  Created by bonhyuk on 4/24/26.
//

import Foundation

// MARK: - 알림 설정

struct NotificationSetting {
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
