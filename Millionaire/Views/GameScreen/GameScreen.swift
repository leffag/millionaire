//
//  GameScreen.swift
//  Millionaire
//
//  Created by Келлер Дмитрий on 22.07.2025.
//

import SwiftUI

struct GameScreen: View {

    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color.answerGradient3.ignoresSafeArea()
                
                VStack {
                    Spacer()
                    answerButtons()
                        .padding(.vertical, 20)
                    helpButtons()
                }
                .padding()
                
            }
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
                action: {}
            )
            
            HelpButton(
                type: .audience,
                action: {}
            )
            
            HelpButton(
                type: .callToFriend,
                action: {}
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
