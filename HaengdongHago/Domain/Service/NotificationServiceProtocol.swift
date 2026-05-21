//
//  NotificationServiceProtocol.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/20/26.
//

import Foundation

protocol NotificationServiceProtocol {
    func initializeReferenceData()
    func requestPermission() async throws
    func reschedule(
        messages: [ActionMessage],
        setting: NotificationSetting
    ) async
    func rescheduleIfNeeded(
        messages: [ActionMessage],
        setting: NotificationSetting
    ) async
    func cancelMotivationNotifications()
}
