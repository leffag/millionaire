//
//  ScoreboardView.swift
//  Millionaire
//
//  Created by Наташа Спиридонова on 25.07.2025.
//


//
//  ScoreboardView.swift
//  Millionaire
//
//  Created by Наташа Спиридонова on 24.07.2025.
//

import SwiftUI

struct ScoreboardView: View {
    @ObservedObject var viewModel: ScoreboardViewModel
    
    var body: some View {
        ZStack {
            // MARK: Background
            LinearGradient(
                colors: [
                    Color(red: 0.13, green: 0.36, blue: 0.75),
                    Color.black
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // MARK: Logo
            Image("Logo")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .offset(y: -300)
                .zIndex(1)
            
            VStack(spacing: 0) {
                // MARK: Top bar
                HStack {
                    Button(action: {}) {
                        Image("IconWithdrawal")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundStyle(.white)
                            .padding(8)
                    }
                    .background(Color.white.opacity(0.15))
                    .clipShape(Circle())
                    .padding(.leading, 16)
                    Spacer()
                }
                // MARK: Scoreboard
                VStack(spacing: 0) {
                    ForEach(viewModel.levels) { level in
                        ScoreboardRowView(level: level)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 100)
                .padding(.bottom, 50)
                Spacer()
            }
        }
    }
}

#Preview {
    ScoreboardView(viewModel: ScoreboardViewModel(currentLevel: 7))
}
