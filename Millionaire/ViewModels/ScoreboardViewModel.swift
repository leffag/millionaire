//
//  ScoreboardViewModel.swift
//  Millionaire
//
//  Created by Наташа Спиридонова on 25.07.2025.
//

import Foundation

final class ScoreboardViewModel: ObservableObject {
    @Published var levels: [ScoreboardRow] = []
    
    private let prizeCalculator = PrizeCalculator()
    
    private var gameSession: GameSession
    init(gameSession: GameSession) {
        self.gameSession = gameSession
        updateLevels()
    }
    
    func updateLevels() {
        let prizes = prizeCalculator.getAllPrizes().reversed()
        self.levels = prizes.map { prize in
            ScoreboardRow(
                id: prize.questionNumber,
                number: prize.questionNumber,
                amount: prize.amount,
                isCheckpoint: prize.isCheckpoint,
                isCurrent: prize.questionNumber == gameSession.currentQuestionIndex+1,
                isTop: prize.questionNumber == 15
            )
        }
    }
}
