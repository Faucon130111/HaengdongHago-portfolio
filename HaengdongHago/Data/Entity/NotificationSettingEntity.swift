//
//  NotificationSettingEntity.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/21/26.
//

import Foundation
import SwiftData

@Model
final class NotificationSettingEntity {
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

extension NotificationSettingEntity {
    func toDomain() -> NotificationSetting {
        NotificationSetting(hour: hour, minute: minute, deliveryMode: deliveryMode)
    }

    static func from(_ domain: NotificationSetting) -> NotificationSettingEntity {
        NotificationSettingEntity(hour: domain.hour, minute: domain.minute, deliveryMode: domain.deliveryMode)
    }
}
