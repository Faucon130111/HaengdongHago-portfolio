//
//  RescheduleNotificationsUseCase.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/21/26.
//

import Foundation

struct RescheduleNotificationsUseCase {
    let messageRepo: ActionMessageRepository
    let settingRepo: NotificationSettingRepository
    let notificationService: NotificationServiceProtocol
    let referenceDateProvider: ReferenceDateProviding
    let scheduler: MotivationScheduler

    func execute() async throws {
        let messages = try messageRepo.fetchAll()
        let setting = try settingRepo.fetch()
        let plans = scheduler.plan(
            messages: messages,
            setting: setting,
            referenceDate: referenceDateProvider.referenceDate()
        )
        await notificationService.schedule(plans)
    }
}
