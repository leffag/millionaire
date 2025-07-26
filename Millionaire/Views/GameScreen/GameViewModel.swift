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
    enum GameNavigationState: Hashable, Equatable {
        case playing
        case showingResult
        case scoreboard(session: GameSession, mode: ScoreboardMode)
    }
    
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
    
    @Published var shouldShowGameOver = false
    @Published var shouldShowVictory = false

    @Published var navigationPath: [GameNavigationState] = [] {
        didSet {
            print("📍 NavigationPath changed: \(navigationPath)")
            print("🔍 shouldShowScoreboard: \(shouldShowScoreboard)")
        }
    }
    
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
        onGameFinished: (() -> Void)? = nil,
        audioService: IAudioService = AudioService(),
        timerService: ITimerService = TimerService()
    ) {
        self.session = initialSession
        self.onSessionUpdated = onSessionUpdated
        self.audioService = audioService
        self.timerService = timerService
        self.onGameFinished = onGameFinished
        
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
        //session = newSession

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

            if answerResult == .correct && !session.isFinished {
                // Подготовка следующего вопроса
                selectedAnswer = nil  // <-- переносим сюда
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
        let targetState: GameNavigationState
        
        if session.isFinished {
            if session.currentQuestionIndex == 14 {
                print(" ПОБЕДА! Выигран миллион!")
                targetState = .scoreboard(session: session, mode: .victory)
            } else {
                print(" Игра окончена на вопросе \(session.currentQuestionIndex + 1)")
                print(" Выигрыш: \(session.score) ")
                targetState = .scoreboard(session: session, mode: .gameOver)
            }
        } else {
            targetState = .scoreboard(session: session, mode: .intermediate)
        }
        
        print("🚀 Adding to navigationPath: \(targetState)")
        navigationPath.append(targetState)
        print("📍 NavigationPath after append: \(navigationPath)")
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
    
    func handleScoreboardDismiss() {
        // Очищаем путь навигации
        navigationPath.removeAll()
        
        // Сбрасываем состояние UI
        selectedAnswer = nil
        correctAnswer = nil
        answerResultState = nil
        
        if !session.isFinished {
            // Если игра продолжается, подготавливаем следующий вопрос
            answers = session.currentQuestion.allAnswers.shuffled()
            startGame()
        } else {
            // Если игра закончена, возвращаемся на главный экран
            // Этот callback можно передать из HomeViewModel
            onGameFinished?()
        }
    }

    
    var shouldShowScoreboard: Bool {
        !navigationPath.isEmpty && navigationPath.contains { state in
            if case .scoreboard = state { return true }
            return false
        }
    }

    var currentScoreboardState: GameNavigationState? {
        navigationPath.first { state in
            if case .scoreboard = state { return true }
            return false
        }
    }

    func dismissScoreboard() {
        navigationPath.removeAll()
        handleScoreboardDismiss()
    }
    
    func testScoreboard() {
        navigationPath.append(.scoreboard(session: session, mode: .gameOver))
    }
}

private extension Question {
    var allAnswers: [String] {
        [correctAnswer] + incorrectAnswers
    }
}

