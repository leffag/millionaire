//
//  ScoreboardViewModel.swift
//  Millionaire
//
//  Created by Наташа Спиридонова on 25.07.2025.
//

import Foundation

final class ScoreboardViewModel: ObservableObject {
    @Published var levels: [ScoreboardRow] = []
    
    private var gameSession: GameSession
    init(gameSession: GameSession) {
        self.gameSession = gameSession
        updateLevels()
    }
    
    func updateLevels() {
        let currentLevel = gameSession.currentQuestionIndex + 1
        let checkpoints = ScoreLogic.checkpointIndices
        let values = ScoreLogic.questionValues.reversed()
        self.levels = zip((1...15).reversed(), values).map { num, amount in
            ScoreboardRow(
                id: num,
                number: num,
                amount: amount,
                isCheckpoint: checkpoints.contains(num),
                isCurrent: num == currentLevel,
                isTop: num == 15
            )
        }
    }
}
