//
//  ScoreboardView.swift
//  Millionaire
//
//  Created by Наташа Спиридонова on 24.07.2025.
//

import SwiftUI

struct ScoreboardView: View {
    @ObservedObject var viewModel: ScoreboardViewModel
    let onAction: () -> Void
    
    init(session: GameSession, mode: GameViewModel.ScoreboardMode, onAction: @escaping () -> Void) {
        self.viewModel = ScoreboardViewModel(gameSession: session)
        self.onAction = onAction
    }
    
    var body: some View {
        ZStack {
            // MARK: Background
            LinearGradient(
                colors: [
                    Color(red: 0.13, green: 0.36, blue: 0.75),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // MARK: Logo
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .offset(y: -300)
                .zIndex(1)
            
            VStack(spacing: 0) {
                // MARK: Top bar
                HStack {
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
                    .padding(.leading, 16)
                    Spacer()
                }
                // MARK: Scoreboard
                VStack(spacing: 0) {
                    ForEach(viewModel.levels) { level in
                        ScoreboardRowView(level: level)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 100)
                .padding(.bottom, 50)
                Spacer()
            }
        }
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
            mode: .intermediate  // или .victory, .gameOver
        ) {
            print("Scoreboard dismissed")  // Заглушка для preview
        }
}

#Preview("Intermediate") {
    let questions = (1...15).map { i in
        Question(
            difficulty: .easy,
            category: "Общие знания",
            question: "Вопрос \(i)?",
            correctAnswer: "A",
            incorrectAnswers: ["B", "C", "D"]
        )
    }
    let session = GameSession(questions: questions, currentQuestionIndex: 5, score: 1000)!
    
    ScoreboardView(
        session: session,
        mode: .intermediate
    ) {
        print("Continue game")
    }
}

#Preview("Victory") {
    let questions = (1...15).map { i in
        Question(
            difficulty: .easy,
            category: "Общие знания",
            question: "Вопрос \(i)?",
            correctAnswer: "A",
            incorrectAnswers: ["B", "C", "D"]
        )
    }
    let session = GameSession(questions: questions, currentQuestionIndex: 14, score: 1000000)!
    
    ScoreboardView(
        session: session,
        mode: .victory
    ) {
        print("Victory!")
    }
}

#Preview("Game Over") {
    let questions = (1...15).map { i in
        Question(
            difficulty: .easy,
            category: "Общие знания",
            question: "Вопрос \(i)?",
            correctAnswer: "A",
            incorrectAnswers: ["B", "C", "D"]
        )
    }
    let session = GameSession(questions: questions, currentQuestionIndex: 8, score: 16000)!
    
    ScoreboardView(
        session: session,
        mode: .gameOver
    ) {
        print("Game over")
    }
}
