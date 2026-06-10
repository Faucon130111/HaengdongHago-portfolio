//
//  NotificationSettingRepository.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/20/26.
//

import Foundation

protocol NotificationSettingRepository {
    func fetch() throws -> NotificationSetting
    func update(_ setting: NotificationSetting) throws
}
