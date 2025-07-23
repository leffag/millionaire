//
//  AnswerButton.swift
//  Millionaire
//
//  Created by Келлер Дмитрий on 22.07.2025.
//

import SwiftUI

// MARK: - Answer Letters (A, B, C, D)
enum AnswerLetter: String, CaseIterable {
    case a = "A", b = "B", c = "C", d = "D"
}

// MARK: - Answer State (normal, correct, incorrect)
enum AnswerState {
    case normal
    case selected
    case correct
    case incorrect
    
    var color: Color {
        switch self {
        case .normal:
            return .answerGradient3
        case .selected:
            return .buttonGradientColorDark
        case .correct:
            return .current1
        case .incorrect:
            return .wrongAnswer2
        }
    }
}

//// MARK: - Answer Button View
//struct AnswerButton: View {
//    let letter: AnswerLetter
//    let text: String
//    let answerState: AnswerState
//    var action: () -> Void
//    
//    @State private var isUsed = false
//    
//    // MARK: - Body
//    var body: some View {
//        Button(action: buttonAction) {
//            HStack {
//                Text("\(letter):")
//                    .font(.headline)
//                    .bold()
//                    .foregroundStyle(.buttonGradientColorDark)
//                
//                Text(text)
//                    .font(.headline)
//                    .foregroundStyle(.white)
//                
//                Spacer()
//            }
//            .padding(.horizontal, 20)
//            .padding(.vertical, 20)
//            .background(
//                MillionaireShapeView(fillColor: answerState.color)
//            )
//        }
//        .disabled(isUsed)
//        .buttonStyle(.plain)
//    }
//    
//    // MARK: - Helper Methods
//    private func buttonAction() {
//        guard !isUsed else { return }
//        isUsed = true
//        action()
//    }
//    
//}
//
//// MARK: - Preview
//#Preview {
//    AnswerButton(
//        letter: .a,
//        text: "Как дела?",
//        answerState: .normal,
//        action: {}
//    )
//}
