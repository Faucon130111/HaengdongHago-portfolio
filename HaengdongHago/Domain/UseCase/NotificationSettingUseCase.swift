//
//  NotificationSettingUseCase.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/21/26.
//

import Foundation

struct NotificationSettingUseCase {
    let settingRepo: NotificationSettingRepository
    let reschedule: RescheduleNotificationsUseCase

    func load() throws -> NotificationSetting {
        try settingRepo.fetch()
    }

    func update(_ setting: NotificationSetting) async throws {
        try settingRepo.update(setting)
        try await reschedule.execute()
    }
}
