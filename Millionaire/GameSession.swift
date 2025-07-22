//
//  GameSession.swift
//  Millionaire
//
//  Created by Effin Leffin on 22.07.2025.
//

import Foundation

struct GameSession {
    let questions: [Question]
    
    var isFinished: Bool
    var currentQuestionIndex: Int
    
    var currentQuestion: Question {
        questions[currentQuestionIndex]
    }
    
    mutating func answer(answer: String) {
        guard !isFinished else {
            return
        }
        
        if answer == currentQuestion.correctAnswer {
            currentQuestionIndex += 1
        } else {
            isFinished = true
        }
    }
}
