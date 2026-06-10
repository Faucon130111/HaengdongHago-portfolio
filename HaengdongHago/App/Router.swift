//
//  Router.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/8/26.
//

import Foundation
import Observation
import SwiftUI

@Observable
final class Router {
    // MARK: 이동 가능한 화면

    enum Destination: Hashable {
        case messageDetail(UUID) // 메시지 상세
        case todoDetail(UUID) // 할 일 상세
    }

    // MARK: 탭

    enum Tab {
        case todo
        case message
    }

    // MARK: State

    var selectedTab: Tab = .todo
    var editingMessageId: UUID?
    var editingTodoId: UUID?

    func navigate(to destination: Destination) {
        switch destination {
        case let .messageDetail(id):
            selectedTab = .message
            editingMessageId = id

        case let .todoDetail(id):
            selectedTab = .todo
            editingTodoId = id
        }
    }

    func selectTab(_ tab: Tab) {
        selectedTab = tab
    }

    // MARK: 알림 userInfo 파싱

    func handle(userInfo: [AnyHashable: Any]) {
        guard let type = userInfo["type"] as? String
        else {
            return
        }

        switch type {
        case "message":
            guard
                let idString = userInfo["id"] as? String,
                let id = UUID(uuidString: idString)
            else {
                selectedTab = .message // id 없으면 탭만 전환
                return
            }
            navigate(to: .messageDetail(id))

        case "todo":
            guard
                let idString = userInfo["id"] as? String,
                let id = UUID(uuidString: idString)
            else {
                selectedTab = .todo // id 없으면 탭만 전환
                return
            }
            navigate(to: .todoDetail(id))

        default:
            break
        }
    }
}
