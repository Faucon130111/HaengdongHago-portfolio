//
//  RescheduleIfNeededUseCase.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/21/26.
//

import Foundation

struct RescheduleIfNeededUseCase {
    let notificationService: NotificationServiceProtocol
    let messageRepo: ActionMessageRepository
    let settingRepo: NotificationSettingRepository

    func execute() async throws {
        let messages = try messageRepo.fetchAll()
        let setting = try settingRepo.fetch()

        await notificationService.rescheduleIfNeeded(
            messages: messages,
            setting: setting
        )
    }
}
