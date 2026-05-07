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
    }

    // MARK: 탭

    enum Tab {
        case today
        case all
        case message
        case more
    }

    // MARK: State

    var selectedTab: Tab = .today
    var messagePath: NavigationPath = .init()

    func navigate(to destination: Destination) {
        switch destination {
        case .messageDetail:
            selectedTab = .message
            messagePath.append(destination)
        }
    }

    func popToRoot() {
        messagePath.removeLast(messagePath.count)
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

        default:
            break
        }
    }
}
