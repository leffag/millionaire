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
    var score: Int
    
    var currentQuestion: Question {
        questions[currentQuestionIndex]
    }
    
    mutating func answer(answer: String) {
        guard !isFinished else {
            return
        }
        
        if answer == currentQuestion.correctAnswer {
            score = ScoreLogic.questionValues[currentQuestionIndex]
            currentQuestionIndex += 1
            
            let hasNextQuestion = currentQuestionIndex + 1 < questions.count
            
            if hasNextQuestion {
                currentQuestionIndex += 1
            } else {
                isFinished = true
            }
            
        } else {
            score = ScoreLogic.findClosestCheckpointScore(questionIndex: currentQuestionIndex)
            isFinished = true
        }
    }
}
