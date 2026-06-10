//
//  AppLogger.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/21/26.
//

import os

extension Logger {
    private static let subsystem = "com.haengdongha"

    static let app = Logger(subsystem: subsystem, category: "App")
    static let notification = Logger(subsystem: subsystem, category: "Notification")
}
