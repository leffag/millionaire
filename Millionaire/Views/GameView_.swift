//
//  GameView.swift
//  Millionaire
//
//  Created by Aleksandr Meshchenko on 21.07.25.
//

import SwiftUI

// MARK: - Temporary GameView for navigation
struct GameView_: View {
    
    @Environment(\.dismiss) private var dismiss
    let gameType: GameType
    
    init(gameType: GameType = .new) {
        self.gameType = gameType
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                HStack {
                    Button("← Назад") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .padding()
                    
                    Spacer()
                }
                
                Spacer()
                
                // Логика для новой или продолженной игры
                Text(gameType == .new ? "New Game" : "Continue Game")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Text("(Здесь будет игра)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
            }
        }
    }
}
