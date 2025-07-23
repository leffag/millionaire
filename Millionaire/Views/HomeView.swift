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

// MARK: - Используем напрямую MillionaireButtonStyle.Variant
typealias ButtonVariant = MillionaireButtonStyle.Variant

struct HomeView: View {
    @State private var showGame = false
    @State private var showRules = false
    @State private var gameType: GameType = .new
    
    // Режим отображения экрана
    @State private var viewMode: HomeViewMode = .firstStart
    
    // Данные для отображения
    @State private var bestScore: Int = 15000
    
    init(viewMode: HomeViewMode = .firstStart, bestScore: Int = 0) {
        self._viewMode = State(initialValue: viewMode)
        self._bestScore = State(initialValue: bestScore)
    }
    
    var body: some View {
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
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showGame) {
            // FIXME: GameView not implemented yet
            // Покажет экран игры с новой/продолженной логикой игры
            // GameView(gameType: gameType)
            
            // TODO: Implement GameView with gameType parameter
            VStack {
                HStack {
                    Spacer()
                    Button("Close") {
                        showGame = false
                    }
                    .padding()
                }
                
                Spacer()
                
                Text("Game Screen - \(gameType == .new ? "New Game" : "Continue")")
                    .font(.title)
                
                Spacer()
            }
            .background(Color.black)
            .foregroundColor(.white)
            // TODO: Implement GameView with gameType parameter
            
        }
        .sheet(isPresented: $showRules) {
            RulesView()
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
            self.gameType = type
            showGame = true
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
