//
//  ActionMessage.swift
//  HaengdongHago
//
//  Created by bonhyuk on 3/26/26.
//

import SwiftData
import Foundation

// MARK: - 발송 방식
enum DeliveryMode: String, Codable {
    case random = "random"
    case sequential = "sequential"
}

// MARK: - 행동 메시지
@Model
class ActionMessage {
    var id: UUID
    var content: String
    var order: Int          // 순서대로 발송 시 사용
    var lastSentAt: Date?   // nil이면 "아직 발신 안 됨"
    var createdAt: Date
    
    init(
        content: String,
        order: Int
    ) {
        self.id = UUID()
        self.content = content
        self.order = order
        self.lastSentAt = nil
        self.createdAt = Date()
    }
}

extension ActionMessage {
    static func defaults() -> [ActionMessage] {
        [
            ActionMessage(
                content: "행동하지 않으면 아무것도 일어나지 않는다",
                order: 0
            ),
            ActionMessage(
                content: "100점짜리 하루보다 70점짜리 7일이 낫다",
                order: 1
            ),
            ActionMessage(
                content: "준비가 됐을 때 시작하는 사람은 영원히 시작 못 한다",
                order: 2
            ),
            ActionMessage(
                content: "완벽한 타이밍은 없다. 지금이 가장 빠른 타이밍이다",
                order: 3
            ),
        ]
    }
    
    var lastSentLabel: String {
        guard let date = self.lastSentAt
        else {
            return "아직 발신 안 됨"
        }
        
        let days = Calendar.current.dateComponents(
            [.day],
            from: date,
            to: Date()
        ).day ?? 0
        
        return days == 0 ? "오늘 발신" : "\(days)일 전 발신"
    }
}
