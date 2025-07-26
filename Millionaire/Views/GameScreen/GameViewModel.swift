//
//  GameViewModel.swift
//  Millionaire
//
//  Created by Келлер Дмитрий on 22.07.2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Navigation States
extension GameViewModel {
    enum ScoreboardMode: Hashable, Equatable {
        case intermediate
        case victory
        case gameOver
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
    
    /// Обработчик завершения игры (возврат на главный экран)
    private let onGameFinished: (() -> Void)?
    
    /// Обработчик перехода к скорборду
    private let onNavigateToScoreboard: ((GameSession, ScoreboardMode) -> Void)?
    
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
    @Published private(set) var timerType: TimerType = .normal
    
    @Published var correctAnswer: String?
    @Published var selectedAnswer: String?
    @Published var answerResultState: AnswerResult?
    
    // Храним текущую задачу для возможности отмены
    private var answerProcessingTask: Task<Void, Never>?
    
    // Важно: отменять задачу при деинициализации
    deinit {
        answerProcessingTask?.cancel()
        
        // Когда GameViewModel уничтожается, все его свойства тоже
        //Если при возврате назад нет этих сообщений - есть утечка!
#if DEBUG
        print(" GameViewModel деинициализирован")
#endif
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
        onGameFinished: (() -> Void)? = nil,
        onNavigateToScoreboard: ((GameSession, ScoreboardMode) -> Void)? = nil,
        audioService: IAudioService = AudioService(),
        timerService: ITimerService = TimerService()
    ) {
        self.session = initialSession
        self.onSessionUpdated = onSessionUpdated
        self.audioService = audioService
        self.timerService = timerService
        self.onGameFinished = onGameFinished
        self.onNavigateToScoreboard = onNavigateToScoreboard
        
        answers = initialSession.currentQuestion.allAnswers.shuffled()
        
        bindTimer()
    }
    
    // MARK: - Game Start
    func startGame() {
        // Стартуем только если нет выбранного ответа
        guard selectedAnswer == nil else { return }
        
        audioService.playGameSfx()
        timerService.start30SecondTimer { [weak self] in
            self?.onTimeExpired()
        }
    }
    
    private func onTimeExpired() {
        audioService.playAnswerLockedSfx()
        stopGameResources()
        
        //  Время вышло - показываем скорборд как поражение
        checkGameEnd()
    }
    
    private func stopGameResources() {
        audioService.stop()
        timerService.stopTimer()
    }
    
    // MARK: - Timer Binding
    private func bindTimer() {
        timerService.progressPublisher
            .map { progress -> (String, TimerType) in
                let totalSeconds = 30
                let elapsed = Int(Float(totalSeconds) * progress)
                let remaining = max(0, totalSeconds - elapsed)
                let minutes = remaining / 60
                let seconds = remaining % 60
                let formatted = String(format: "%02d:%02d", minutes, seconds)
                let type = TimerType.getType(for: remaining)
                return (formatted, type)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] formatted, type in
                self?.duration = formatted
                self?.timerType = type
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Answer Tap
    func onAnswer(_ answer: String) {
        // Отменяем предыдущую задачу, если она есть
        answerProcessingTask?.cancel() // Если пользователь быстро нажал другой ответ
        
        // обновляем значение выделленного ответа
        selectedAnswer = answer
        
        // Запускаем новую
        answerProcessingTask = Task {
            await processAnswerWithDelay(answer: answer)
        }
    }
    
    @MainActor
    private func processAnswerWithDelay(answer: String) async {
        
        // Cтавим на паузу таймер
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
        session = newSession
        
        // Звук
        switch answerResult {
        case .correct:
            answerResultState = .correct
        case .incorrect:
            answerResultState = .incorrect
        }
        
        // Ждём анимации результата
        do {
            try await Task.sleep(for: .seconds(2))
            try Task.checkCancellation()
            
            if answerResult == .correct && !session.isFinished {
                // Подготовка следующего вопроса
                selectedAnswer = nil  // <-- переносим сюда
                answerResultState = nil
                correctAnswer = nil
                answers = session.currentQuestion.allAnswers.shuffled()
                startGame()
            } else {
                // Игра окончена
                checkGameEnd()
            }
            
        } catch {
            // Отменено
            audioService.stop()
        }
    }
    
    private func checkGameEnd() {
        let mode: ScoreboardMode
        
        if session.isFinished {
            if session.currentQuestionIndex == 14 {
                print(" ПОБЕДА! Выигран миллион!")
                mode = .victory
            } else {
                print(" Игра окончена на вопросе \(session.currentQuestionIndex + 1)")
                print(" Выигрыш: \(session.score) ")
                mode = .gameOver
            }
        } else {
            mode = .intermediate
        }
        
        // Делегируем навигацию родительскому компоненту
        onNavigateToScoreboard?(session, mode)
    }
    
    // MARK: - Help Button Actions
    func fiftyFiftyButtonTap() {
        guard let result = session.useFiftyFiftyLifeline() else {
            return
        }

        // Обновляем сессию
        session = session // Триггерим onSessionUpdated

        // Помечаем недоступные ответы
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
    
    func testScoreboard() {
        stopGameResources()
        onNavigateToScoreboard?(session, .intermediate)
    }
}

private extension Question {
    var allAnswers: [String] {
        [correctAnswer] + incorrectAnswers
    }
}

extension GameViewModel {
    // MARK: - Game Control Methods
    
    /// Ставит игру на паузу (при уходе с экрана)
    func pauseGame() {
        timerService.pauseTimer()
        audioService.pause()
    }
    
    /// Возобновляет игру (при возврате на экран)
    func resumeGame() {
        // Возобновляем только если нет выбранного ответа
        guard selectedAnswer == nil else { return }
        
        timerService.resumeTimer()
        audioService.resume()
    }
    
    /// Полностью останавливает игру (при выходе)
    func stopGame() {
        answerProcessingTask?.cancel()
        stopGameResources()
    }
}
