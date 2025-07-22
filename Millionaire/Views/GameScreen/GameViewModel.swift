//
//  GameViewModel.swift
//  Millionaire
//
//  Created by Келлер Дмитрий on 22.07.2025.
//

import Foundation

final class GameViewModel: ObservableObject {
    
    var numberQuestion = 0
    var totalQuestion: Int
    
    
    init(totalQuestion: Int) {
        self.totalQuestion = totalQuestion
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
