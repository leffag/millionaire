//
//  GameScreen.swift
//  Millionaire
//
//  Created by Келлер Дмитрий on 22.07.2025.
//

import SwiftUI

struct GameScreen: View {
    @StateObject var viewModel: GameViewModel

    //    MARK: Init
    init() {
        self._viewModel = StateObject(wrappedValue: GameViewModel())
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color.answerGradient3.ignoresSafeArea()
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
                .padding(20)
            }
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
            Text(viewModel.question?.question ?? "Как дела?")
                .font(.headline)
                .foregroundStyle(.white)
                .bold()
            Spacer()
        }
    }
    
    // MARK: - Answer Buttons
    private func answerButtons() -> some View {
        VStack(spacing: 20) {
            AnswerButton(
                letter: AnswerLetter.a,
                text: "",
                answerState: AnswerState.normal,
                action: {}
            )
            
            AnswerButton(
                letter: AnswerLetter.b,
                text: "",
                answerState: AnswerState.normal,
                action: {}
            )
            
            AnswerButton(
                letter: AnswerLetter.c,
                text: "",
                answerState: AnswerState.normal,
                action: {}
            )
            
            AnswerButton(
                letter: AnswerLetter.d,
                text: "",
                answerState: AnswerState.normal,
                action: {}
            )
        }
    }
    
    // MARK: - Help Buttons
    private func helpButtons() -> some View {
        HStack(spacing: 20) {
            HelpButton(
                type: .fiftyFifty,
                action: viewModel.fiftyFiftyButtonTap
            )
            
            HelpButton(
                type: .audience,
                action: viewModel.audienceButtonTap
            )
            
            HelpButton(
                type: .callToFriend,
                action: viewModel.callYourFriendButtonTap
            )
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        GameScreen()
    }
}
