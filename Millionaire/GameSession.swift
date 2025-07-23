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
    var lifelines: Set<Lifeline>
    
    var currentQuestion: Question {
        questions[currentQuestionIndex]
    }
    
    init?(
        questions: [Question],
        isFinished: Bool = false,
        currentQuestionIndex: Int = 0,
        score: Int = 0,
        lifelines: Set<Lifeline> = [.fiftyFifty, .callAFriend, .audience]
    ) {
        guard
            questions.count == 15,
            0..<15 ~= currentQuestionIndex
        else {
            return nil
        }
        
        self.questions = questions
        self.isFinished = isFinished
        self.currentQuestionIndex = currentQuestionIndex
        self.score = score
        self.lifelines = lifelines
    }
    
    mutating func answer(answer: String) {
        guard !isFinished else {
            return
        }
        
        if answer == currentQuestion.correctAnswer {
            score += ScoreLogic.questionValues[currentQuestionIndex]
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
    
    mutating func useLifeline(lifeline: Lifeline) {
        guard !isFinished else {
            return
        }
        
        if lifelines.contains(lifeline) {
            lifelines.remove(lifeline)
        } else {
            return
        }
    }
}
