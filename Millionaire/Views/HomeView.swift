//
//  HomeView.swift
//  Millionaire
//
//  Created by Aleksandr Meshchenko on 21.07.25.
//

import SwiftUI

struct HomeView: View {
    @State private var showGame = false
    @State private var showRules = false
    
    var body: some View {
        ZStack {
            // Фоновый градиент
            LinearGradient(
                colors: [
                    Color(red: 0.063, green: 0.055, blue: 0.086),
                    Color(red: 0.216, green: 0.298, blue: 0.58)
                ],
                startPoint: UnitPoint(x: 0.5, y: 0.75),
                endPoint: UnitPoint(x: 0.5, y: 0.25)
            )
            .ignoresSafeArea()
            
            // Кнопка Rules в правом верхнем углу
            VStack {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        showRules = true
                    }) {
                        Image("HelpButton")
                            .font(.title2)
                    }
                    .padding(.top, 20)
                    .padding(.trailing, 20)
                }
                
                Spacer()
            }
            
            VStack {
                Spacer()
                
                // Лого и название игры из ресурсов
                Image("HomeScreenLogo")
                    .frame(width: 311, height: 287)
                
                Spacer()
                
                // Кнопка New Game внизу
                VStack(spacing: 20) {
                    Button(action: {
                        showGame = true
                    }) {
                        ZStack {
                            Image("PrimaryButton")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 60)
                            
                            Text("New game")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .shadow(color: Color.yellow.opacity(0.5), radius: 10, x: 0, y: 5)
                    .scaleEffect(showGame ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: showGame)
                    
                    // Отступ от нижнего края
                    Spacer()
                        .frame(height: 50)
                }
                .padding(.horizontal, 40)
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showGame) {
            GameView()
        }
        .sheet(isPresented: $showRules) {
            RulesView()
        }
    }
}

// MARK: - Preview
#Preview {
    HomeView()
}
