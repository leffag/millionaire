//
//  GameManager.swift
//  Millionaire
//
//  Created by Effin Leffin on 24.07.2025.
//

import Foundation

/// Менеджер, хранящий актуальные данные об игре
final class GameManager {
    private let networkService: NetworkService
    
    /// Лучший результат, если он есть
    private(set) var bestScore: Int
    
    /// Модель последней игры, если она есть
    var lastSession: GameSession? {
        didSet {
            updateBestScoreIfNeeded()
        }
    }
    
    init(
        networkService: NetworkService = .shared,
        bestScore: Int = 0,
        lastSession: GameSession? = nil
    ) {
        self.networkService = networkService
        
        // TODO: Добавить чтение начальных значений из UserDefaults?
        self.bestScore = bestScore
        self.lastSession = lastSession
    }
    
    /// Начинает новую игру
    func startNewGame() async throws -> GameSession {
        let questions = try await networkService.fetchQuestions(from: QuestionsAPI.baseURL)
        
        guard let initialSession = GameSession(questions: questions) else {
            throw StartGameFailure.invalidQuestions
        }
        
        self.lastSession = initialSession
        
        return initialSession
    }
    
    /// Актуализирует лучший результат при изменении сессии
    private func updateBestScoreIfNeeded() {
        // Результат применяем только для завершенной игры
        guard let lastSession, lastSession.isFinished else {
            return
        }
        
        // Сохраним результат, если он оказался больше ранее сохраненного
        bestScore = max(bestScore, lastSession.score)
    }
}

private extension GameManager {
    enum StartGameFailure: Error {
        case invalidQuestions
    }
}
