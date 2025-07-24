//
//  Prize.swift
//  Millionaire
//
//  Created by Aleksandr Meshchenko on 24.07.25.
//

import Foundation

struct Prize: Equatable {
    let questionNumber: Int
    let amount: Int
    let isCheckpoint: Bool
    
    var formatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return "\(formatter.string(from: NSNumber(value: amount))!) ₽"
    }
}
