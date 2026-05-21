//
//  ReferenceDateProviding.swift
//  HaengdongHago
//
//  Created by bonhyuk on 5/21/26.
//

import Foundation

protocol ReferenceDateProviding {
    /// 메시지 순환의 기준일. 최초 호출 시 생성·영속화된다.
    func referenceDate() -> Date
}
