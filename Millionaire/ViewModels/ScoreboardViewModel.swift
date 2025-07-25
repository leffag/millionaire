//
//  ScoreboardViewModel.swift
//  Millionaire
//
//  Created by Наташа Спиридонова on 25.07.2025.
//

import Foundation

final class ScoreboardViewModel: ObservableObject {
    @Published var levels: [ScoreboardRow] = []
    
    init(currentLevel: Int = 7) {
        let values = [
            1000000,
            500000,
            250000,
            100000,
            50000,
            25000,
            15000,
            12500,
            10000,
            7500,
            5000,
            3000,
            2000,
            1000,
            500
        ]
        let checkpoints = [10, 5]
        self.levels = (1...15).reversed().enumerated().map { idx, num in
            ScoreboardRow(
                id: num,
                number: num,
                amount: values[idx],
                isCheckpoint: checkpoints.contains(num),
                isCurrent: num == currentLevel,
                isTop: num == 15
            )
        }
    }
}
