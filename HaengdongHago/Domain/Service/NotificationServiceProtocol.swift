//
//  NotificationServiceProtocol.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/20/26.
//

import Foundation

protocol NotificationServiceProtocol {
    func requestPermission() async throws
    func schedule(_ plans: [PlannedNotification]) async
    func pendingMotivationCount() async -> Int
}
