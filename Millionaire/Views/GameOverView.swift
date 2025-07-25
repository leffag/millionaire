//
//  GameOverView.swift
//  Millionaire
//
//  Created by Александр Пеньков on 22.07.2025.
//

import SwiftUI

struct GameOverView: View {
    var body: some View {
        ZStack {
            backgroundImage
            
            VStack(spacing: 0) {
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, -80)
                VStack(spacing: 8) {
                    Text("Game Over!")
                        .foregroundStyle(.white)
                        .font(Font.custom("SF Compact Display", size: 32))
                        .fontWeight(.semibold)
                    
                    Text("level 8")
                        .foregroundStyle(.white.opacity(0.6))
                        .font(Font.custom("SF Compact Display", size: 16))
                        .fontWeight(.regular)
                    HStack() {
                        Text("$15,000")
                            .foregroundStyle(.white)
                            .font(Font.custom("SF Compact Display", size: 24))
                            .fontWeight(.semibold)
                        Image(.coin)
                    }
                }
                .padding(.top, -100)
                
                Spacer()
                
                VStack(spacing: 46) {
                    Button.millionaire("New game", variant: .primary) {
                        print("New game")
                    }
                    .padding(.top, 40)
                    Button("Main screen") {
                        print("Main screen")
                    }
                    .millionaireStyle(.regular)
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    @ViewBuilder
    private var backgroundImage: some View {
        Image("Background")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .ignoresSafeArea(.all)
    }
}

#Preview {
    GameOverView()
}
