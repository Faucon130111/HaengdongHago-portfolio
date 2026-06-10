//
//  SetupNotificationUseCase.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/20/26.
//

import Foundation

struct SetupNotificationUseCase {
    let notificationService: NotificationServiceProtocol
    let reschedule: RescheduleNotificationsUseCase

    func execute() async throws {
        try await notificationService.requestPermission()
        try await reschedule.execute()
    }
}
