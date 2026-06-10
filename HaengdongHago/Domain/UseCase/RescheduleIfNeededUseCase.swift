//
//  RescheduleIfNeededUseCase.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/21/26.
//

import Foundation

struct RescheduleIfNeededUseCase {
    let notificationService: NotificationServiceProtocol
    let reschedule: RescheduleNotificationsUseCase
    var threshold: Int = 10

    func execute() async throws {
        let remaining = await notificationService.pendingMotivationCount()
        guard remaining < threshold else { return }
        try await reschedule.execute()
    }
}
