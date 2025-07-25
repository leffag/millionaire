//
//  GameViewModel.swift
//  Millionaire
//
//  Created by Келлер Дмитрий on 22.07.2025.
//

import Foundation
import Combine

// MARK: - Navigation States
extension GameViewModel {
    enum GameNavigationState {
        case playing
        case showingResult
        case gameOver(score: Int, questionReached: Int)
        case victory(score: Int)
    }
}

// локальное UI состояние + управление сервисами
final class GameViewModel: ObservableObject {
    
    // MARK: - Services
    let timerService: ITimerService
    let audioService: IAudioService
    
    private var cancellables = Set<AnyCancellable>()
    private let prizeCalculator = PrizeCalculator()
    
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
    
    // Доп состояния для UI
    @Published var correctAnswer: String?
    @Published var selectedAnswer: String?
    @Published var answerResultState: AnswerResult?
    
//    @Published private(set) var isProcessingAnswer = false
//    @Published private(set) var showResult = false
//    @Published private(set) var lastAnswerWasCorrect = false
  
    
    
    @Published var shouldShowGameOver = false
    @Published var shouldShowVictory = false
    
    @Published var navigationState: GameNavigationState = .playing
    
    // Храним текущую задачу для возможности отмены
    private var answerProcessingTask: Task<Void, Never>?
    
    // Важно: отменять задачу при деинициализации
    deinit {
        answerProcessingTask?.cancel()
    }
    
    var question: Question { session.currentQuestion }
    
    var numberQuestion: Int { session.currentQuestionIndex + 1 }
    
    var priceQuestion: String {
        prizeCalculator
            .getPrizeAmount(for: session.currentQuestionIndex)
            .formatted()
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
    func onAnswer(_ answer: String) {
        // Предотвращаем множественные нажатия
//           guard !isProcessingAnswer else { return }
        
            // Отменяем предыдущую задачу, если она есть
            answerProcessingTask?.cancel() // Если пользователь быстро нажал другой ответ

       
//        обновляем значение выделленного ответа
        selectedAnswer = answer
        
        // Запускаем новую
        answerProcessingTask = Task {
            await processAnswerWithDelay(answer: answer)
        }
    }
    
    @MainActor
    private func processAnswerWithDelay(answer: String) async {
//        isProcessingAnswer = true
        
        //   Cтавим на паузу таймер
        timerService.pauseTimer()
        
        // Играем звук интриги
        audioService.playAnswerLockedSfx()
        
        do {
            // Ждем для драматизма
            try await Task.sleep(for: .seconds(3))
            
            // Проверяем, не была ли задача отменена
            try Task.checkCancellation()
            
            // Обрабатываем ответ
            await processAnswer(answer)
            
        } catch {
            // Задача была отменена
//            isProcessingAnswer = false
            audioService.stop()
        }
    }
    
    @MainActor
    private func processAnswer(_ answer: String) async {
        var newSession = session
        
        // Сохраняем выбранный ответ — важно для подсветки
        selectedAnswer = answer
        correctAnswer = newSession.currentQuestion.correctAnswer
        
        // Обрабатываем ответ — получаем результат, но не начисляем тут ничего
        guard let answerResult = newSession.answer(answer: answer) else {
//            isProcessingAnswer = false
            return
        }

        // Начисляем призы исподбзуя PrizeCalculator
        switch answerResult {
        case .correct:
            let prize = prizeCalculator.getPrizeAmount(for: session.currentQuestionIndex)
            newSession.addScore(prize)
        case .incorrect:
            let checkpoint = prizeCalculator.getCheckpointPrizeAmount(before: session.currentQuestionIndex)
            newSession.setScore(checkpoint)
        }

        // Обновляем сессию
//        session = newSession
//        showResult = true
//        lastAnswerWasCorrect = answerResult == .correct

        // Звук
        switch answerResult {
        case .correct:
            answerResultState = .correct
            audioService.playCorrectAnswerSfx()
        case .incorrect:
            answerResultState = .incorrect
            audioService.playWrongAnswerSfx()
        }

        // Ждём анимации результата
        do {
            try await Task.sleep(for: .seconds(2))
            try Task.checkCancellation()

//            showResult = false
//            isProcessingAnswer = false

//            if answerResult == .correct && !session.isFinished {
//                // Подготовка следующего вопроса
//                selectedAnswer = nil  // <-- переносим сюда
//                answers = session.currentQuestion.allAnswers.shuffled()
////                startGame()
//            } else {
//                // Игра окончена
//                checkGameEnd()
//            }

        } catch {
            // Отменено
//            showResult = false
//            isProcessingAnswer = false
        }
    }
    
    private func checkGameEnd() {
        if session.isFinished {
            if session.currentQuestionIndex == 14 {
//                удалил && lastAnswerWasCorrect
                print(" ПОБЕДА! Выигран миллион!")
                navigationState = .victory(score: session.score)
                //audioService.playVictorySfx()
            } else {
                print(" Игра окончена на вопросе \(session.currentQuestionIndex + 1)")
                print(" Выигрыш: \(session.score) ")
                navigationState = .gameOver(
                    score: session.score,
                    questionReached: session.currentQuestionIndex + 1
                )
            }
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
        print(result)
        // TODO: Реализация подсказки
    }
    
    func callYourFriendButtonTap() {
        guard let result = session.useCallToFriendLifeline() else {
            // Подсказка недоступна, не делаем ничего
            return
        }
        print(result)
        // TODO: Реализация подсказки
    }
}

private extension Question {
    var allAnswers: [String] {
        [correctAnswer] + incorrectAnswers
    }
}

