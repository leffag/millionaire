//
//  ScoreboardView.swift
//  Millionaire
//
//  Created by Наташа Спиридонова on 24.07.2025.
//

import SwiftUI

struct ScoreboardView: View {
    @ObservedObject var viewModel: ScoreboardViewModel
    let mode: GameViewModel.ScoreboardMode
    let onAction: () -> Void      // Для withdrawal (выдача награды)
    let onClose: () -> Void       // Для закрытия экрана
    
    init(session: GameSession,
         mode: GameViewModel.ScoreboardMode = .intermediate,
         onAction: @escaping () -> Void,
         onClose: @escaping () -> Void) {
        self.viewModel = ScoreboardViewModel(gameSession: session)
        self.mode = .intermediate
        self.onAction = onAction
        self.onClose = onClose
    }
    
    var body: some View {
        ZStack {
            // MARK: Background
            Image("Background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .ignoresSafeArea(.all)
            
            // MARK: Logo
            Image("ScoreboardScreenLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 85, height: 85)
                .offset(y: -300)
                .zIndex(1)
            
            VStack(spacing: 0) {
                // MARK: Top bar
                HStack {
                    // Кнопка withdrawal показывается только в промежуточном режиме
                    if mode == .intermediate {
                        Button(action: {
                            onAction()
                        }) {
                            Image("IconWithdrawal")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundStyle(.white)
                                .padding(8)
                        }
                        .background(Color.white.opacity(0.15))
                        .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        onClose()  // Закрытие экрана
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding(8)
                    }
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
                
                // MARK: Scoreboard
                VStack(spacing: 0) {
                    ForEach(viewModel.levels) { level in
                        ScoreboardRowView(level: level)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 40)
                .padding(.bottom, 50)
                
                Spacer()
            }
        }
        .safeAreaInset(edge: .top) {
            // Добавляем прозрачную область для безопасной зоны
            Color.clear.frame(height: 0)
        }
        .navigationBarHidden(true) // Скрываем навигационную панель
    }
}

#Preview {
    let questions = (1...15).map { i in
        Question(
            difficulty: .easy,
            category: "Общие знания",
            question: "Вопрос?",
            correctAnswer: "A",
            incorrectAnswers: ["B", "C", "D"]
        )
    }
    let session = GameSession(questions: questions, currentQuestionIndex: 0, score: 0)!
    
    ScoreboardView(
        session: session,
        mode: .intermediate,
        onAction: {
            print("Withdrawal action")
        },
        onClose: {
            print("Close action")
        }
    )
}
