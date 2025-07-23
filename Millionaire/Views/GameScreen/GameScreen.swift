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
    @State private var gameType: GameType
    
    //    MARK: Init
    init(gameType: GameType) {
        self.gameType = gameType
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
                let index = viewModel.answers.firstIndex(where: { $0.id == answer.id }) ?? 0
                let letter = AnswerLetter.allCases[index]
                let state = viewModel.answerStates[answer.id] ?? .normal
                let isDisabled = viewModel.selectedAnswer != nil

                Button {
                    if viewModel.selectedAnswer == nil {
                        viewModel.selectAnswer(answer)
                    } else {
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.error)
                        showAlreadyAnsweredAlert = true
                    }
                } label: {
                    HStack {
                        Text("\(letter.rawValue):")
                            .bold()
                            .foregroundColor(.white)

                        Text(answer.text)
                            .foregroundColor(.white)

                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
                .millionaireStyle(
                    styleForAnswerState(state),
                    isEnabled: !isDisabled
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
    
    private func styleForAnswerState(_ state: AnswerState) -> MillionaireButtonStyle.Variant {
        switch state {
        case .normal:
            return .answerRegular
        case .selected:
            return .primary
        case .correct:
            return .answerCorrect
        case .incorrect:
            return .answerWrong
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        GameScreen(gameType: GameType.continued)
    }
}
