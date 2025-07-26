//
//  NavigationCoordinator.swift
//  Millionaire
//
//  Created by Aleksandr Meshchenko on 26.07.25.
//

import SwiftUI

//
// Поток навигации:
//
//HomeView
//    ├── LoadingView
//    ├── GameScreen
//    │   └── ScoreboardView (через toolbar button)
//    │       ├── [intermediate] → назад к GameScreen
//    │       └── [gameOver/victory] → GameOverView
//    └── GameOverView
//        ├── New Game → HomeView → LoadingView → GameScreen
//        └── Main Screen → HomeView

// MARK: - Navigation Routes
enum NavigationRoute: Hashable {
    case loading
    case game(GameSession)
    case scoreboard(GameSession, GameViewModel.ScoreboardMode)
    case gameOver(GameSession, GameViewModel.ScoreboardMode)
}

// MARK: - Navigation Coordinator
@MainActor
final class NavigationCoordinator: ObservableObject {
    @Published var path: [NavigationRoute] = []
    
    // Dependencies
    private weak var gameManager: GameManager?
    private weak var homeViewModel: HomeViewModel?
    
    // MARK: - Setup
    func setup(gameManager: GameManager, homeViewModel: HomeViewModel) {
        self.gameManager = gameManager
        self.homeViewModel = homeViewModel
    }
    
    // MARK: - Navigation Methods
    
    func showLoading() {
        path = [.loading]
    }
    
    func showGame(_ session: GameSession) {
        path = [.game(session)]
    }
    
    func showScoreboard(_ session: GameSession, mode: GameViewModel.ScoreboardMode) {
        path.append(.scoreboard(session, mode))
    }
    
    func showGameOver(_ session: GameSession, mode: GameViewModel.ScoreboardMode) {
        // Убираем scoreboard и показываем game over
        if path.last?.isScoreboard == true {
            path.removeLast()
        }
        path.append(.gameOver(session, mode))
    }
    
    func popToRoot() {
        path.removeAll()
    }
    
    func popLast() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func handleScoreboardClose(mode: GameViewModel.ScoreboardMode, session: GameSession) {
        switch mode {
        case .intermediate:
            // В промежуточном режиме - возвращаемся к игре
            popLast()
        case .gameOver, .victory:
            // При окончании игры - переходим к GameOverView
            showGameOver(session, mode: mode)
        }
    }
    
    // MARK: - View Factory
    @ViewBuilder
    func destinationView(for route: NavigationRoute) -> some View {
        switch route {
        case .loading:
            LoadingView()
                .navigationBarBackButtonHidden(true)
            
        case .game(let session):
            GameScreen(
                viewModel: createGameViewModel(for: session)
            )
            
        case .scoreboard(let session, let mode):
            ScoreboardView(
                session: session,
                mode: mode,
                onAction: { [weak self] in
                    // Логика withdrawal - забрать деньги и завершить игру
                    self?.homeViewModel?.withdrawAndEndGame()
                },
                onClose: { [weak self] in
                    //                    Логика переходов от ScoreboardView:
                    //                    .intermediate → возврат к игре
                    //                    .gameOver/.victory → переход к GameOverView
                    
                    // Возвращаемся назад - убираем скорборд из навигации
                    self?.handleScoreboardClose(mode: mode, session: session)
                }
            )
            
        case .gameOver(let session, let mode):
            //            Обработка действий из GameOverView:
            //            "New Game" → очистка навигации и запуск новой игры
            //            "Main Screen" → очистка навигации и возврат на главный
            GameOverView(
                session: session,
                mode: mode,
                onNewGame: { [weak self] in
                    // Очищаем навигацию и начинаем новую игру
                    self?.popToRoot()
                    self?.homeViewModel?.startNewGame()
                },
                onMainScreen: { [weak self] in
                    // Возвращаемся на главный экран
                    self?.popToRoot()
                }
            )
        }
    }
    
    // MARK: - ViewModels Factory
    private func createGameViewModel(for session: GameSession) -> GameViewModel {
        GameViewModel(
            initialSession: session,
            onSessionUpdated: { [weak self] updatedSession in
                self?.gameManager?.updateSession(updatedSession)
            },
            onGameFinished: { [weak self] in
                // Возвращаемся на главный экран
                self?.popToRoot()
            },
            // GameViewModel не управляет навигацией
            // Вместо этого уведомляет родительский компонент
            onNavigateToScoreboard: { [weak self] session, mode in
                // Добавляем скорборд в навигацию
                self?.showScoreboard(session, mode: mode)
            }
        )
    }
}

// MARK: - Helper Extensions
private extension NavigationRoute {
    var isScoreboard: Bool {
        if case .scoreboard = self { return true }
        return false
    }
}
