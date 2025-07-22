//
//  GameViewModel.swift
//  Millionaire
//
//  Created by Келлер Дмитрий on 22.07.2025.
//

import Foundation

final class GameViewModel: ObservableObject {
    let networkService: NetworkService
    
    let duration: String = "00:00"
    let question: Question? = nil
    let difficult: QuestionDifficulty = .easy
    let numberQuestion = 0
    let priceQuestion: String = "100"

    
//    MARK: Init
    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
    }
    
    // MARK: - Game State
    func startGame() {

    }
    
    func stopGame() {
        
    }
    
    func gameOver() {
        
    }
    
    
    // MARK: - Help Button Actions
    func fiftyFiftyButtonTap() {
        
    }
    
    func audienceButtonTap() {
        
    }
    
    func callYourFriendButtonTap() {
        
    }
}
