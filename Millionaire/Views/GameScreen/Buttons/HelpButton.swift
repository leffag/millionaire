//
//  HelpButton.swift
//  Millionaire
//
//  Created by Келлер Дмитрий on 22.07.2025.
//

import SwiftUI

// MARK: - Lifeline Types
enum TypeButton {
    case fiftyFifty
    case audience
    case callToFriend
    
    var imageName: Image {
        switch self {
        case .fiftyFifty:
            return Image(.lifeline50)
        case .audience:
            return Image(.lifelineAudience)
        case .callToFriend:
            return Image(.lifelineCall)
        }
    }
}

// MARK: - Help Button View
struct HelpButton: View {
    let type: TypeButton
    let action: () -> Void

    @State private var isUsed = false
    
    // MARK: - Body
    var body: some View {
        Button(action: buttonAction) {
            type.imageName
                .resizable()
                .scaledToFit()
                .opacity(isUsed ? 0.3 : 1.0)
        }
        .disabled(isUsed)
    }
    
    // MARK: - Helper Methods
    private func buttonAction() {
        guard !isUsed else { return }
        isUsed = true
        action()
    }
}

// MARK: - Preview
#Preview {
    HelpButton(type: .callToFriend, action: {})
}
