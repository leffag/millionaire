//
//  GameViewModel.swift
//  Millionaire
//
//  Created by Келлер Дмитрий on 22.07.2025.
//

import Foundation

final class GameViewModel: ObservableObject {
    @Published private var session: GameSession
    
    /// Массив вариантов ответа в порядке их отображения
    @Published private(set) var answers: [String] {
        didSet {
            // Очищаем недоступные варианты при смене ответов (а значит и вопроса)
            disabledAnswers = []
        }
    }
    
    /// Недоступные для выбора варианты ответов
    @Published private(set) var disabledAnswers: Set<Int> = []
    
    let duration: String = "00:00"
    
    var question: Question { session.currentQuestion }
    
    let difficult: QuestionDifficulty = .easy
    
    var numberQuestion: Int { session.currentQuestionIndex + 1 }
    
    var priceQuestion: String {
        ScoreLogic.questionValues[session.currentQuestionIndex].formatted()
    }
    
    var lifelines: Set<Lifeline> { session.lifelines }
    
//    MARK: Init
    init(initialSession: GameSession) {
        self.session = initialSession
        
        answers = initialSession.currentQuestion.allAnswers.shuffled()
    }
    
    func onAnswer(index: Int) {
        var newSession = session
        
        guard let answerResult = newSession.answer(answer: answers[index]) else {
            return
        }
        
        switch answerResult {
        case .correct:
            // Ответили верно
            // TODO: Тут можем поморгать кнопкой ответа
            
            session = newSession
            answers = session.currentQuestion.allAnswers.shuffled()
            
        case .incorrect:
            // Ответили неверно
            // TODO: Тут можем поморгать кнопкой ответа
            
            session = newSession
        }
    }
    
    // MARK: - Help Button Actions
    func fiftyFiftyButtonTap() {
        guard !session.isFinished else {
            return
        }
        
        guard session.lifelines.contains(.fiftyFifty) else {
            return
        }
        
        session.useLifeline(lifeline: .fiftyFifty)
        
        guard
            let correctAnswerIndex = answers.firstIndex(of: question.correctAnswer)
        else {
            return
        }
        
        let incorrectIndices = answers
            .indices
            .filter { $0 != correctAnswerIndex }
            .shuffled()
        
        disabledAnswers.insert(incorrectIndices[0])
        disabledAnswers.insert(incorrectIndices[1])
    }
    
    func audienceButtonTap() {
        guard !session.isFinished else {
            return
        }
        
        guard session.lifelines.contains(.audience) else {
            return
        }
        
        session.useLifeline(lifeline: .audience)
        
        // TODO: Реализация подсказки
    }
    
    func callYourFriendButtonTap() {
        guard !session.isFinished else {
            return
        }
        
        guard session.lifelines.contains(.callToFriend) else {
            return
        }
        
        session.useLifeline(lifeline: .callToFriend)
        
        // TODO: Реализация подсказки
    }
}

private extension Question {
    var allAnswers: [String] {
        [correctAnswer] + incorrectAnswers
    }
}
