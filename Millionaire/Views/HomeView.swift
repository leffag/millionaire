//
//  HomeView.swift
//  Millionaire
//
//  Created by Aleksandr Meshchenko on 21.07.25.
//

import SwiftUI

enum HomeViewMode {
    case firstStart
    case secondStart
    case notCompletedGame
    
    /// Вспомогательный инит для создания на основе флагов наличия сессии и наличия лучшего результата
    init(hasActiveSession: Bool, hasScore: Bool) {
        if hasActiveSession {
            self = .notCompletedGame
        }
        else {
            self = hasScore ? .secondStart : .firstStart
        }
    }
}

enum GameType {
    case new
    case continued
    
    var buttonTitle: String {
        switch self {
        case .new:
            return "New game"
        case .continued:
            return "Continue game"
        }
    }
}

// MARK: - Используем напрямую MillionaireButtonStyle.Variant
typealias ButtonVariant = MillionaireButtonStyle.Variant

struct HomeView: View {
    
    @StateObject private var viewModel: HomeViewModel
    @State private var showRules = false
    
    @EnvironmentObject var gameManager: GameManager
    
    init(gameManager: GameManager) {
        self._viewModel = StateObject(wrappedValue: HomeViewModel(gameManager: gameManager))
    }
    
    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            ZStack {
                backgroundImage
                
                // Кнопка Rules
                VStack {
                    helpButton
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    
                    // Лого и название игры из ресурсов
                    logoAndScoreSection
                    
                    Spacer()
                    
                    // Кнопка New Game внизу
                    actionButtons
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showRules) {
                RulesView()
            }
            .alert("Ошибка", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                Text(viewModel.errorMessage)
            }
            .navigationDestination(for: HomeViewModel.NavigationRoute.self) { route in
                destinationView(for: route)
            }
        }
        .onChange(of: viewModel.navigationPath) { newPath in
            viewModel.onNavigationChange(newPath)
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var backgroundImage: some View {
        Image("Background")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .ignoresSafeArea(.all)
    }
    
    @ViewBuilder
    private var helpButton: some View {
        HStack {
            Spacer()
            
            Button(action: {
                showRules = true
            }) {
                Image("HelpButton")
                    .font(.title2)
            }
            .padding(.top, 20)
            .padding(.trailing, 20)
        }
    }
    
    @ViewBuilder
    private var logoAndScoreSection: some View {
        VStack() {
            Image(.homeScreenLogo)
                .frame(width: 311, height: 287)
            // Лучший счет
            if viewModel.viewMode != .firstStart {
                bestScoreView
                    .padding(.top, 60)
            }
        }
    }
    
    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 20) {
            // Кнопки игры
            switch viewModel.viewMode {
            case .firstStart, .secondStart:
                gameButton(
                    for: .new,
                    variant: .primary,
                    action: viewModel.startNewGame
                )
                
            case .notCompletedGame:
                gameButton(
                    for: .continued,
                    variant: .primary,
                    action: viewModel.continueGame
                )
                
                gameButton(
                    for: .new,
                    variant: .regular,
                    action: viewModel.startNewGame
                )
            }
            
            Spacer()
                .frame(height: 50)
        }
        .padding(.horizontal, 40)
    }
    
    @ViewBuilder
    private func gameButton(for type: GameType,
                            variant: ButtonVariant,
                            action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(type.buttonTitle)
        }
        .millionaireStyle(variant)
        .frame(maxWidth: .infinity)
        .disabled(viewModel.isLoading)
    }
    
    @ViewBuilder
    private var bestScoreView: some View {
        VStack {
            Text("All-time Best Score:")
                .font(.body)
                .foregroundColor(.white.opacity(0.7))
            HStack {
                Image("Coin")
                Text(viewModel.bestScore, format: .currency(code: Locale.current.currency?.identifier ?? "₽"))
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for route: HomeViewModel.NavigationRoute) -> some View {
        switch route {
            
        case .loading:
            LoadingView()
            
        case .game(let session):
            GameScreen(
                viewModel: viewModel.createGameViewModel(for: session)
            )
            
        case .scoreboard(let session, let mode):
            ScoreboardView(
                session: session,
                mode: mode,
                onAction: {
                    print(" Withdrawal tapped")
                    // Логика withdrawal - забрать деньги и завершить игру
                    viewModel.withdrawAndEndGame()
                },
                onClose: {
//                    Логика переходов от ScoreboardView:
//                    .intermediate → возврат к игре
//                    .gameOver/.victory → переход к GameOverView
                    
                    // Возвращаемся назад - убираем скорборд из навигации
                    switch mode {
                    case .intermediate:
                        // В промежуточном режиме - возвращаемся к игре
                        viewModel.navigationPath.removeLast()
                    case .gameOver, .victory:
                        // При окончании игры - переходим к GameOverView
                        viewModel.navigationPath.removeLast() // Убираем scoreboard
                        viewModel.navigationPath.append(.gameOver(session, mode))
                    }
                }
            )
            
        case .gameOver(let session, let mode):
//            Обработка действий из GameOverView:
//            "New Game" → очистка навигации и запуск новой игры
//            "Main Screen" → очистка навигации и возврат на главный
            GameOverView(
                session: session,
                mode: mode,
                onNewGame: {
                    // Очищаем навигацию и начинаем новую игру
                    viewModel.navigationPath.removeAll()
                    viewModel.startNewGame()
                },
                onMainScreen: {
                    // Возвращаемся на главный экран
                    viewModel.navigationPath.removeAll()
                }
            )
        }
        
    }
    
}

// MARK: - Preview
#Preview("First Start") {
    HomeView(
        gameManager: GameManager()
    )
}

#Preview("Second Start with Best Score") {
    HomeView(
        gameManager: GameManager(bestScore: 125000)
    )
}

#Preview("Not Completed Game") {
    HomeView(
        gameManager: GameManager(
            bestScore: 32000,
            lastSession: .preview()
        )
    )
}

private extension GameSession {
    /// Создает тестовую сессию для использования в превью
    static func preview() -> Self {
        GameSession(
            questions: Array(
                repeating: Question(difficulty: .easy, category: "aaa", question: "Как дела?", correctAnswer: "Хорошо", incorrectAnswers: Array(repeating: "Плохо", count: 3)),
                count: 15
            )
        )!
    }
}
