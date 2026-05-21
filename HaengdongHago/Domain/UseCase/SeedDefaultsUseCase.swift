//
//  SeedDefaultsUseCase.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/21/26.
//

import Foundation

struct SeedDefaultsUseCase {
    let messageRepo: ActionMessageRepository

    func execute() throws {
        guard try messageRepo.fetchCount() == 0
        else {
            return
        }

        for message in ActionMessage.defaults() {
            try messageRepo.add(message)
        }

        try messageRepo.save()
    }
}
