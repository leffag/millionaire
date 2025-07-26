//
//  HomeViewModel.swift
//  Millionaire
//
//  Created by Aleksandr Meshchenko on 25.07.25.
//

import Foundation
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var viewMode: HomeViewMode = .firstStart
    @Published var bestScore: Int = 0
    @Published var navigationPath: [NavigationRoute] = []
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    
    // MARK: - Dependencies
    private var gameManager: GameManager
    
    // MARK: - Computed Properties
    var hasActiveGame: Bool {
        gameManager.currentSession?.isFinished == false
    }
    
    // MARK: - Init
    init(gameManager: GameManager) {
        self.gameManager = gameManager
        updateViewState()
    }
    
    func onNavigationChange(_ path: [NavigationRoute]) {
        if path.isEmpty {
            // Вернулись на главный экран
            updateViewState()
        }
    }
    
    func startNewGame() {
        Task {
            await startGame(type: .new)
        }
    }
    
    func continueGame() {
        Task {
            await startGame(type: .continued)
        }
    }
    
    // MARK: - Private Methods
    private func updateViewState() {
        
        viewMode = HomeViewMode(
            hasActiveSession: gameManager.currentSession?.isFinished == false,
            hasScore: gameManager.bestScore > 0
        )
        bestScore = gameManager.bestScore
    }
    
    private func startGame(type: GameType) async {
        switch type {
        case .new:
            await startNewGameFlow()
            
        case .continued:
            continueExistingGame()
        }
    }
    
    private func startNewGameFlow() async {
        
        // Показываем загрузку
        navigationPath = [.loading]
        isLoading = true
        
        do {
            let session = try await gameManager.startNewGame()
            
            // Небольшая задержка для UX
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            // Переходим к игре
            navigationPath = [.game(session)]
        } catch {
            // Обработка ошибки
            navigationPath = []
            errorMessage = "Не удалось загрузить вопросы. Проверьте интернет-соединение."
            showError = true
        }
        
        isLoading = false
    }
    
    private func continueExistingGame() {
        guard let session = gameManager.currentSession, !session.isFinished else {
            errorMessage = "Нет активной игры для продолжения"
            showError = true
            return
        }
        
        navigationPath = [.game(session)]
    }
    
    // MARK: - Game Session Updates
    func createGameViewModel(for session: GameSession) -> GameViewModel {
            GameViewModel(
                initialSession: session,
                onSessionUpdated: { [weak self] updatedSession in
                    self?.gameManager.updateSession(updatedSession)
                },
                onGameFinished: { [weak self] in
                    // Возвращаемся на главный экран
                    self?.navigationPath.removeAll()
                },
                // GameViewModel не управляет навигацией
                // Вместо этого уведомляет родительский компонент
                onNavigateToScoreboard: { [weak self] session, mode in
                    // Добавляем скорборд в навигацию
                    self?.navigationPath.append(.scoreboard(session, mode))
                }
            )
        }
}

// MARK: - Navigation Routes
extension HomeViewModel {
    enum NavigationRoute: Hashable {
        case loading
        case game(GameSession)
        case scoreboard(GameSession, GameViewModel.ScoreboardMode)
    }
}
