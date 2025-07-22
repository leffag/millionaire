//
//  GameView.swift
//  Millionaire
//
//  Created by Aleksandr Meshchenko on 21.07.25.
//

import SwiftUI

// MARK: - Temporary GameView for navigation
struct GameView: View {
    @Environment(\.dismiss) private var dismiss
    
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
                
                Text("Игровой экран")
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
