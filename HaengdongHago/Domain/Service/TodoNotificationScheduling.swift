//
//  TodoNotificationScheduling.swift
//  HaengdongHago
//
//  Created by bonhyuk on 6/10/26.
//

import Foundation

/// 할 일 단건 알림 스케줄링 추상화.
/// 동기부여 알림(30일 배치 교체)과 달리, 항목당 1개를 특정 일시에 단발성으로 등록한다.
protocol TodoNotificationScheduling {
    func schedule(id: UUID, title: String, body: String, at fireDate: Date) async
    func cancel(id: UUID) async
}
