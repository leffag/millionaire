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

enum NavigationRoute: Hashable {
    case loading
    case game(GameSession)
}

// MARK: - Используем напрямую MillionaireButtonStyle.Variant
typealias ButtonVariant = MillionaireButtonStyle.Variant

struct HomeView: View {
    private let gameManager: GameManager
    
    @State private var showRules = false
    
    // Режим отображения экрана
    @State private var viewMode: HomeViewMode = .firstStart
    
    // Данные для отображения
    @State private var bestScore: Int = 15000
    
    @State private var navigationPath: [NavigationRoute] = []
    
    init(gameManager: GameManager) {
        self.gameManager = gameManager
        
        let viewMode = HomeViewMode(
            hasActiveSession: gameManager.lastSession?.isFinished == false,
            hasScore: gameManager.bestScore > 0
        )
        
        self._viewMode = State(initialValue: viewMode)
        self._bestScore = State(initialValue: gameManager.bestScore)
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
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
                    logoSection
                    
                    Spacer()
                    
                    // Кнопка New Game внизу
                    actionButtons
                }
                .background(Color.black)
                .foregroundColor(.white)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showRules) {
                RulesView()
            }
            .navigationDestination(for: NavigationRoute.self) { route in
                switch route {
                case .game(let session):
                    GameScreen(
                        viewModel: GameViewModel(
                            initialSession: session,
                            onSessionUpdated: {
                                // При изменении игры на игровом экране актуализируем
                                // состояние в менеджере
                                //
                                // Это не приведёт к обновлению стейта viewMode, но нам это пока не нужно,
                                // чтобы не перестроилась вся иерархия стека навигации
                                gameManager.lastSession = $0
                            }
                        )
                    )
                    
                case .loading:
                    ZStack {
                        backgroundImage
                        
                        ProgressView()
                            .tint(.white)
                    }
                }
            }
        }
        .onChange(of: navigationPath) { newValue in
            if newValue == [] {
                // Вернулись на главный экран, обновим данные для отображения из менеджера
                // Важно делать это по возвращению, а не прямо во время игры, иначе получаем баги на игровом экране
                viewMode = gameManager.lastSession?.isFinished == false ? .notCompletedGame : .firstStart
                bestScore = gameManager.bestScore
            }
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
    private var logoSection: some View {
        Image("HomeScreenLogo")
            .frame(width: 311, height: 287)
    }
    
    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 20) {
            if viewMode != .firstStart {
                bestScoreLabel
            }
            
            if viewMode != .notCompletedGame {
                gameButton(
                    for: .new,
                    variant: .primary
                )
            }
            if viewMode == .notCompletedGame {
                gameButton(
                    for: .continued,
                    variant: .primary
                )
                gameButton(
                    for: .new,
                    variant: .regular
                )
            }
            
            Spacer()
                .frame(height: 50)
        }
        .padding(.horizontal, 40)
    }
  
    @ViewBuilder
    private func gameButton(for type: GameType, variant: ButtonVariant) -> some View {
        Button(action: {
            Task {
                await startGame(type: type)
            }
        }) {
            Text(type.buttonTitle)
        }
        .millionaireStyle(variant)
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private var bestScoreLabel: some View {
        VStack {
            Text("All-time Best Score:")
                .font(.body)
                .foregroundColor(.white.opacity(0.7))
            HStack {
                Image("Coin")
                Text("\(bestScore.formatted()) ₽")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
        }
    }
    
    private func startGame(type: GameType) async {
        switch type {
        case .new:
            do {
                // Покажем экран загрузки на время загрузки данных
                navigationPath = [.loading]
                
                // Пытаемся получить игровую сессию
                let initialSession = try await gameManager.startNewGame()
                
                // Показываем игровой экран с этой сессией
                navigationPath = [.game(initialSession)]
            }
            catch {
                // Что-то пошло не так, возвращаемся в корень навигации
                navigationPath = []
            }
            
        case .continued:
            // Для продолжения игры обязательно должна быть ранее запущенная активная сессия
            guard
                let session = gameManager.lastSession,
                !session.isFinished
            else {
                return
            }
            
            // Показываем игровой экран с этой сессией
            navigationPath = [.game(session)]
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
