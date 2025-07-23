//
//  GameScreen.swift
//  Millionaire
//
//  Created by Келлер Дмитрий on 22.07.2025.
//

import SwiftUI

struct GameScreen: View {
    @StateObject var viewModel: GameViewModel
    @State private var showAlreadyAnsweredAlert = false
    
    //    MARK: Init
    init() {
        self._viewModel = StateObject(wrappedValue: GameViewModel())
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
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
                .padding(20)
                .allowsHitTesting(viewModel.selectedAnswer == nil)
            }
        }
        .alert(
            "You have already selected an answer",
               isPresented: $showAlreadyAnsweredAlert)
        {
            Button("OK", role: .cancel) {}
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
            ForEach(viewModel.answers) { answer in
                AnswerButton(
                    letter: AnswerLetter.allCases[viewModel.answers.firstIndex(where: { $0.id == answer.id }) ?? 0],
                    text: answer.text,
                    answerState: viewModel.answerStates[answer.id] ?? .normal,
                    action: {
                        if viewModel.selectedAnswer == nil {
                            viewModel.selectAnswer(answer)
                        } else {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.error)
                            showAlreadyAnsweredAlert = true
                        }
                    }
                )
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
