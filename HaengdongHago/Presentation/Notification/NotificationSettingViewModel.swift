//
//  NotificationSettingViewModel.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/21/26.
//

import Foundation

@Observable
final class NotificationSettingViewModel {
    private(set) var hour: Int = 7
    private(set) var minute: Int = 0
    private(set) var deliveryMode: DeliveryMode = .random

    private let settingRepo: NotificationSettingRepository

    init(settingRepo: NotificationSettingRepository) {
        self.settingRepo = settingRepo
        load()
    }

    func load() {
        guard let setting = try? settingRepo.fetch() else { return }
        hour = setting.hour
        minute = setting.minute
        deliveryMode = setting.deliveryMode
    }

    func updateTime(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
        persist()
    }

    func updateDeliveryMode(_ mode: DeliveryMode) {
        deliveryMode = mode
        persist()
    }

    private func persist() {
        let setting = NotificationSetting(hour: hour, minute: minute, deliveryMode: deliveryMode)
        try? settingRepo.update(setting)
        NotificationCenter.default.post(name: .notificationSettingDidChange, object: nil)
    }
}
