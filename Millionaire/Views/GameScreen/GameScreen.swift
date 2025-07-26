//
//  GameScreen.swift
//  Millionaire
//
//  Created by Келлер Дмитрий on 22.07.2025.
//

import SwiftUI

struct GameScreen: View {
    @ObservedObject var viewModel: GameViewModel
    
    @State private var showCustomAlert = false
    @State private var alertMessage = ""
    
    //    MARK: Init
    init(viewModel: GameViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            AnimatedGradientBackgroundView()
            
            VStack {
                timerView()
                    .padding(.top, 20)
                
                questionTextView()
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                
                answerButtons()
                    .padding(.vertical, 20)
                helpButtons()
            }
            .blur(radius: showCustomAlert ? 5 : 0)
            .allowsHitTesting(viewModel.selectedAnswer == nil)
            .padding(20)
        }
        .onAppear {
            viewModel.startGame()
        }
        
        .overlay(
            Group {
                if showCustomAlert {
                    CustomAlertView(message: alertMessage ) {
                        withAnimation(.easeInOut) {
                            showCustomAlert = false
                        }
                    }
                    .frame(width: 350, height: 500)
                    .cornerRadius(20)
                    .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                    .zIndex(2)
                }
            }
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackBarButtonView()
            }
            
            ToolbarItem(placement: .principal) {
                navTitle()
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    //viewModel.navigationPath.append(.scoreboard(session: viewModel.currentSession,
                    //                                            mode: .gameOver))
                    viewModel.testScoreboard()
                }) {
                    Image(ImageResource.iconLevels)
                }
            }
        }
        //  Добавляем навигацию к скорборду
        .fullScreenCover(
            isPresented: .constant(viewModel.shouldShowScoreboard),
            onDismiss: {
                viewModel.handleScoreboardDismiss()
            }
        ) {
            if let scoreboardState = viewModel.currentScoreboardState,
               case .scoreboard(let session, let mode) = scoreboardState {
                ScoreboardView(session: session, mode: mode) {
                    viewModel.handleScoreboardDismiss()
                }
            }
        }
    }
    
    
    // MARK: - NavTitle
    private func navTitle() -> some View {
        HStack {
            VStack {
                Text("QUESTION #\(viewModel.numberQuestion)")
                    .millionaireTitleStyle()
                  
                
                
                Text("$\(viewModel.priceQuestion)")
                    .millionaireTitleStyle()
            }
        }
    }
    
    // MARK: - Timer View
    private func timerView() -> some View {
        ZStack {
            Text(viewModel.duration)
                .millionaireTimerStyle(type: viewModel.timerType)
        }
    }
    
    // MARK: - Question View
    private func questionTextView() -> some View {
        VStack {
            Text(viewModel.question.question)
                .font(.headline)
                .foregroundStyle(.white)
                .bold()
            Spacer()
        }
    }
    
    
    // MARK: - Answer Buttons
    private func answerButtons() -> some View {
        VStack(spacing: 20) {
            ForEach(Array(zip(AnswerLetter.allCases, viewModel.answers)), id: \.0) { letter, answer in
                Button.millionaireAnswer(
                    letter: letter.rawValue,
                    text: answer,
                    state: buttonState(for: answer)
                ) {
                    viewModel.onAnswer(answer)
                }
                .disabled(viewModel.selectedAnswer == answer)
            }
        }
    }
    
    
    // MARK: - Help Buttons
    private func helpButtons() -> some View {
        HStack(spacing: 20) {
            HelpButton(
                type: .fiftyFifty,
                action: viewModel.fiftyFiftyButtonTap
            )
            .disabled(!viewModel.lifelines.contains(.fiftyFifty))
            
            HelpButton(
                type: .audience,
                action: {
                    viewModel.audienceButtonTap()
                    alertMessage = "Аудитория выбрала: C"
                    withAnimation {
                        showCustomAlert = true
                    }
                }
            )
            .disabled(!viewModel.lifelines.contains(.audience))
            
            HelpButton(
                type: .callToFriend,
                action: viewModel.callYourFriendButtonTap
            )
            .disabled(!viewModel.lifelines.contains(.callToFriend))
        }
    }
    

    
    private func buttonState(for answer: String) -> MillionaireAnswerButtonStyle.AnswerState {
        guard let selected = viewModel.selectedAnswer else {
            return .regular
        }

        // Подсвечиваем выбранную кнопку
        if selected == answer {
            switch viewModel.answerResultState {
            case .correct:
                return .correct
            case .incorrect:
                return .wrong
            case .none:
                return .regular
            }
        }

        // Если выбран неправильный ответ, но это — правильный
        if viewModel.answerResultState == .incorrect,
           answer == viewModel.correctAnswer {
            return .correct
        }

        return .regular
    }
    
    @ViewBuilder
    private func destinationView(for state: GameViewModel.GameNavigationState) -> some View {
        switch state {
        case .scoreboard(let session, let mode):
            ScoreboardView(
                session: session,
                mode: mode
            ) {
                viewModel.handleScoreboardDismiss()
            }
        case .playing, .showingResult:
            EmptyView()
        }
    }
    
    
}

// MARK: - Preview
#Preview {
    NavigationStack {
        GameScreen(
            viewModel: GameViewModel(
                initialSession: GameSession(
                    questions: Array(
                        repeating: Question(difficulty: .easy, category: "aaa", question: "Как дела?", correctAnswer: "Хорошо", incorrectAnswers: Array(repeating: "Плохо", count: 3)),
                        count: 15
                    )
                )!
            )
        )
    }
}
