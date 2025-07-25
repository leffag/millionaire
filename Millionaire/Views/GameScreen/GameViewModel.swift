//
//  GameViewModel.swift
//  Millionaire
//
//  Created by Келлер Дмитрий on 22.07.2025.
//

import Foundation
import Combine

final class GameViewModel: ObservableObject {
    
    // MARK: - Services
    let timerService: ITimerService
    let audioService: IAudioService

    private var cancellables = Set<AnyCancellable>()
    
    
    /// Обработчик изменения состояния игры
    private let onSessionUpdated: (GameSession) -> Void
    
    @Published private var session: GameSession {
        didSet {
            // Сообщаем обработчику об изменении состояния игры
            onSessionUpdated(session)
        }
    }
    
    /// Массив вариантов ответа в порядке их отображения
    @Published private(set) var answers: [String] {
        didSet {
            // Очищаем недоступные варианты при смене ответов (а значит и вопроса)
            disabledAnswers = []
        }
    }
    
    /// Недоступные для выбора варианты ответов
    @Published private(set) var disabledAnswers: Set<String> = []
    
    @Published var duration: String = "00:00"
    
    var question: Question { session.currentQuestion }
    
    let difficult: QuestionDifficulty = .easy
    
    var numberQuestion: Int { session.currentQuestionIndex + 1 }
    
    var priceQuestion: String {
        ScoreLogic.questionValues[session.currentQuestionIndex].formatted()
    }
    
    var lifelines: Set<Lifeline> { session.lifelines }
    
//    MARK: Init
    init(
        initialSession: GameSession,
        onSessionUpdated: @escaping (GameSession) -> Void = { _ in },
        audioService: IAudioService = AudioService(),
        timerService: ITimerService = TimerService()
    ) {
        self.session = initialSession
        self.onSessionUpdated = onSessionUpdated
        self.audioService = audioService
        self.timerService = timerService
        
        answers = initialSession.currentQuestion.allAnswers.shuffled()
        
        bindTimer()
    }
    

    
    // MARK: - Game Start
    func startGame() {
        audioService.playGameSfx()

        timerService.start30SecondTimer { [weak self] in
            self?.onTimeExpired()
        }
    }
    
    private func onTimeExpired() {
        audioService.playAnswerLockedSfx()
        stopGameResources()
    }

    private func stopGameResources() {
        audioService.stop()
        timerService.stopTimer()
    }
    // MARK: - Timer Binding
       private func bindTimer() {
           timerService.progressPublisher
               .map { progress in
                   let totalSeconds: Int = 30
                   let elapsed = Int(Float(totalSeconds) * progress)
                   let remaining = max(0, totalSeconds - elapsed)
                   let minutes = remaining / 60
                   let seconds = remaining % 60
                   return String(format: "%02d:%02d", minutes, seconds)
               }
               .receive(on: DispatchQueue.main)
               .assign(to: &$duration)
       }
    
    // MARK: - Answer Tap
    func onAnswer(letter: AnswerLetter) {
        stopGameResources()
        
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
