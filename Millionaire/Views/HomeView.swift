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
    @State private var showRules = false
    
    // Режим отображения экрана
    @State private var viewMode: HomeViewMode = .firstStart
    
    // Данные для отображения
    @State private var bestScore: Int = 15000
    
    @State private var navigationPath: [NavigationRoute] = []
    
    init(viewMode: HomeViewMode = .firstStart, bestScore: Int = 0) {
        self._viewMode = State(initialValue: viewMode)
        self._bestScore = State(initialValue: bestScore)
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                // Фоновый градиент
                backgroundGradient
                
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
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showRules) {
                // FIXME: RulesView not implemented yet
                // Покажет правила игры и инструкции
                // RulesView()
            }
            .navigationDestination(for: NavigationRoute.self) { route in
                switch route {
                case .game(let session):
                    GameScreen(
                        viewModel: GameViewModel(initialSession: session)
                    )
                    
                case .loading:
                    ZStack {
                        // Фоновый градиент
                        backgroundGradient
                        
                        ProgressView()
                            .tint(.white)
                    }
                }
            }
        }
    }
    
    
    // MARK: - View Components
    
    @ViewBuilder
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.063, green: 0.055, blue: 0.086),
                Color(red: 0.216, green: 0.298, blue: 0.58)
            ],
            startPoint: UnitPoint(x: 0.5, y: 0.75),
            endPoint: UnitPoint(x: 0.5, y: 0.25)
        )
        .ignoresSafeArea()
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
        .millionaireStyle(variant, isEnabled: true)
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
        navigationPath = [.loading]
        
        switch type {
        case .new:
            do {
                let questions = try await NetworkService.shared.fetchQuestions(from: QuestionsAPI.baseURL)
                
                guard let initialSession = GameSession(questions: questions) else {
                    throw StartGameFailure.invalidQuestions
                }
                
                navigationPath = [.game(initialSession)]
            }
            catch {
                navigationPath = []
            }
            
        case .continued:
            // FIXME: Реализовать продолжение игры
            navigationPath = []
        }
        
        enum StartGameFailure: Error {
            case invalidQuestions
        }
    }
    
}

// MARK: - Preview
#Preview("First Start") {
    HomeView(viewMode: .firstStart)
}

#Preview("Second Start with Best Score") {
    HomeView(viewMode: .secondStart, bestScore: 125000)
}

#Preview("Not Completed Game") {
    HomeView(viewMode: .notCompletedGame, bestScore: 32000)
}
