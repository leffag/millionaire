//
//  GameScreen.swift
//  Millionaire
//
//  Created by Келлер Дмитрий on 22.07.2025.
//

import SwiftUI

struct GameScreen: View {
    @ObservedObject var viewModel: GameViewModel
    
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
            //.allowsHitTesting(viewModel.selectedAnswer == nil)
            .padding(20)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                navTitle()
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(ImageResource.iconLevels)
                }
            }
        }
    }
    
    
    // MARK: - NavTitle
    private func navTitle() -> some View {
        HStack {
            VStack {
                Text("QUESTION #\(viewModel.numberQuestion)")
                    .font(.title)
                    .foregroundStyle(.white)
                
                
                Text("$\(viewModel.priceQuestion)")
                    .font(.title)
                    .foregroundStyle(.white)
                    .bold()
            }
        }
    }
    
    // MARK: - Timer View
    private func timerView() -> some View {
        ZStack {
            Text(viewModel.duration)
                .font(.title)
                .foregroundStyle(.white)
                .bold()
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
                    state: .regular
                ) {
                    viewModel.onAnswer(letter: letter)
                }
                .disabled(viewModel.disabledAnswers.contains(answer))
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
                action: viewModel.audienceButtonTap
            )
            .disabled(!viewModel.lifelines.contains(.audience))
            
            HelpButton(
                type: .callToFriend,
                action: viewModel.callYourFriendButtonTap
            )
            .disabled(!viewModel.lifelines.contains(.callToFriend))
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
