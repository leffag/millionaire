//
//  GameOverView.swift
//  Millionaire
//
//  Created by Александр Пеньков on 22.07.2025.
//

import SwiftUI

struct GameOverView: View {
    var body: some View {
        VStack(spacing: 0) {
            Image(.logo)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 50)
            VStack(spacing: 8) {
                Text("Game Over!")
                    .font(.system(size: 32, weight: .semibold, design: .default))
                    .foregroundStyle(.white)
                
                Text("level 8")
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundStyle(.white.opacity(0.6))
                HStack() {
                    Image(.coin)
                    Text("$15,000")
                        .font(.system(size: 24, weight: .semibold, design: .default))
                        .foregroundStyle(.white)
                }
            }
            .padding(.top, -120)
            
            Spacer()
            
            VStack(spacing: 16) {
                Button("New game", action: {

                })
                Button("Main screen", action: {

                })
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(.backgroundBlueLight)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    GameOverView()
}
