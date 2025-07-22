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
}

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
        .fullScreenCover(isPresented: $showGame) {
            GameView_(gameType: gameType)
        }
        .sheet(isPresented: $showRules) {
            RulesView()
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
                showButton(
                    title: "New game",
                    imageName: "PrimaryButton",
                    action: {
                        gameType = .new
                        showGame = true
                    }
                )
            }
            if viewMode == .notCompletedGame {
                showButton(
                    title: "Continue game",
                    imageName: "PrimaryButton",
                    action: {
                        gameType = .continued
                        showGame = true
                    }
                )
                showButton(
                    title: "New game",
                    imageName: "PrimaryButton",
                    action: {
                        gameType = .new
                        showGame = true
                    }
                )
            }
            
            Spacer()
                .frame(height: 50)
        }
        .padding(.horizontal, 40)
    }
    
    @ViewBuilder
    private func showButton(title: String, imageName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 60)
                
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: .infinity)
        .shadow(color: Color.yellow.opacity(0.5), radius: 10, x: 0, y: 5)
        .scaleEffect(showGame ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: showGame)
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
