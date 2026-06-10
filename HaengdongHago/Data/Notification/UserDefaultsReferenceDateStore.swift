//
//  UserDefaultsReferenceDateStore.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/21/26.
//

import Foundation

final class UserDefaultsReferenceDateStore: ReferenceDateProviding {
    private static let key = "motivationReferenceDate"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func referenceDate() -> Date {
        if let date = defaults.object(forKey: Self.key) as? Date {
            return date
        }

        let now = Date()
        defaults.set(now, forKey: Self.key)
        return now
    }
}
