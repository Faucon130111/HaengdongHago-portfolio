//
//  SetupNotificationUseCase.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/20/26.
//

import Foundation

struct SetupNotificationUseCase {
    let notificationService: NotificationServiceProtocol
    let messageRepo: ActionMessageRepository
    let settingRepo: NotificationSettingRepository

    func execute() async throws {
        try await notificationService.requestPermission()

        let messages = try messageRepo.fetchAll()
        let setting = try settingRepo.fetch()
        print("⚙️ [App] 메시지 \(messages.count)개, 알림 시간 \(setting.hour):\(String(format: "%02d", setting.minute))")

        await notificationService.reschedule(
            messages: messages,
            setting: setting
        )
    }
}
