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
    @Published private(set) var disabledAnswers: Set<String> = []
    
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
    
    func onAnswer(letter: AnswerLetter) {
        let answerIndex = letter.answerIndex
        
        var newSession = session
        
        guard let answerResult = newSession.answer(answer: answers[answerIndex]) else {
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
        guard let result = session.useFiftyFiftyLifeline() else {
            // Подсказка недоступна, не делаем ничего
            return
        }
        
        // Помечаем полученные от подсказки ответы как недоступные к выбору
        disabledAnswers = result.disabledAnswers
    }
    
    func audienceButtonTap() {
        guard let result = session.useAudienceLifeline() else {
            // Подсказка недоступна, не делаем ничего
            return
        }
        
        // TODO: Реализация подсказки
    }
    
    func callYourFriendButtonTap() {
        guard let result = session.useCallToFriendLifeline() else {
            // Подсказка недоступна, не делаем ничего
            return
        }
        
        // TODO: Реализация подсказки
    }
}

private extension Question {
    var allAnswers: [String] {
        [correctAnswer] + incorrectAnswers
    }
}

private extension AnswerLetter {
    var answerIndex: Int {
        Self.allCases.firstIndex(of: self)!
    }
}
