//
//  AnswerButton.swift
//  Millionaire
//
//  Created by Келлер Дмитрий on 22.07.2025.
//

import SwiftUI

// MARK: - Answer Letters (A, B, C, D)
enum AnswerLetter: CaseIterable {
    case a, b, c, d
    
    var letter: String {
        switch self {
        case .a: return "A"
        case .b: return "B"
        case .c: return "C"
        case .d: return "D"
        }
    }
}

// MARK: - Answer State (normal, correct, incorrect)
enum AnswerState {
    case normal
    case correct
    case incorrect
    
    var color: Color {
        switch self {
        case .normal:
            return .answerGradient3
        case .correct:
            return .current1
        case .incorrect:
            return .wrongAnswer2
        }
    }
}

// MARK: - Answer Button View
struct AnswerButton: View {
    let letter: AnswerLetter
    let text: String
    let answerState: AnswerState
    var action: () -> Void
    
    // MARK: - Body
    var body: some View {
        Button(action: action) {
            HStack {
                Text("\(letter.letter):")
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.buttonGradientColorDark)
                
                Text(text)
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
            .background(
                MillionaireShapeView(fillColor: answerState.color)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    AnswerButton(
        letter: .a,
        text: "Как дела?",
        answerState: .normal,
        action: {}
    )
}
