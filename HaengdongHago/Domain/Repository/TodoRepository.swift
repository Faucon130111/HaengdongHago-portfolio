//
//  TodoRepository.swift
//  HaengdongHago
//
//  Created by bonhyuk on 6/10/26.
//

import Foundation

protocol TodoRepository {
    func fetchAll() throws -> [Todo]
    func add(_ todo: Todo) throws
    func update(_ todo: Todo) throws
    func delete(_ todo: Todo) throws
}
