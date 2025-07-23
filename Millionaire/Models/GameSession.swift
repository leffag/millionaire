//
//  GameSession.swift
//  Millionaire
//
//  Created by Effin Leffin on 22.07.2025.
//

import Foundation

enum AnswerResult {
    case correct
    case incorrect
}

struct GameSession: Hashable {
    let questions: [Question]
    
    private(set) var isFinished: Bool
    private(set) var currentQuestionIndex: Int
    private(set) var score: Int
    private(set) var lifelines: Set<Lifeline>
    
    var currentQuestion: Question {
        questions[currentQuestionIndex]
    }
    
    init?(
        questions: [Question],
        isFinished: Bool = false,
        currentQuestionIndex: Int = 0,
        score: Int = 0,
        lifelines: Set<Lifeline> = [.fiftyFifty, .callToFriend, .audience]
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
    
    mutating func answer(answer: String) -> AnswerResult? {
        guard !isFinished else {
            return nil
        }
        
        if answer == currentQuestion.correctAnswer {
            score += ScoreLogic.questionValues[currentQuestionIndex]
            
            let hasNextQuestion = currentQuestionIndex + 1 < questions.count
            
            if hasNextQuestion {
                currentQuestionIndex += 1
            } else {
                isFinished = true
            }
            
            return .correct
        } else {
            score = ScoreLogic.findClosestCheckpointScoreIndex(questionIndex: currentQuestionIndex)
            isFinished = true
            return .incorrect
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
