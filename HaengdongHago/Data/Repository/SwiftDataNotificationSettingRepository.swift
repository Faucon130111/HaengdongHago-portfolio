//
//  SwiftDataNotificationSettingRepository.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/20/26.
//

import Foundation
import SwiftData

final class SwiftDataNotificationSettingRepository: NotificationSettingRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetch() throws -> NotificationSetting {
        let entities = try context.fetch(FetchDescriptor<NotificationSettingEntity>())
        if let existing = entities.first {
            return existing.toDomain()
        }

        let newEntity = NotificationSettingEntity()
        context.insert(newEntity)
        try context.save()

        return newEntity.toDomain()
    }

    func update(_ setting: NotificationSetting) throws {
        let entities = try context.fetch(FetchDescriptor<NotificationSettingEntity>())
        if let entity = entities.first {
            entity.hour = setting.hour
            entity.minute = setting.minute
            entity.deliveryMode = setting.deliveryMode
        } else {
            context.insert(NotificationSettingEntity.from(setting))
        }
        try context.save()
    }
}
