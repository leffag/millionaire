//
//  RulesView.swift
//  Millionaire
//
//  Created by Aleksandr Meshchenko on 22.07.25.
//

import SwiftUI

// MARK: - Temporary RulesView for modal
struct RulesView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Темно-серый фон rgba(49, 52, 69, 1)
                Color(red: 49/255, green: 52/255, blue: 69/255)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                       
                        Text("Добро пожаловать в игру 'Кто хочет стать миллионером?'")
                            .font(.headline)
                            .foregroundStyle(.white)
                        
                        Text("Игра состоит из 15 вопросов с возрастающей сложностью. Ваша цель - дать правильный ответ на каждый вопрос и дойти до главного приза в 1,000,000 рублей!")
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.9))
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Несгораемые суммы:")
                                .font(.headline)
                                .foregroundStyle(.white)
                            
                            Text("• 1,000 рублей (вопрос 5)")
                                .foregroundStyle(.white.opacity(0.9))
                            Text("• 32,000 рублей (вопрос 10)")
                                .foregroundStyle(.white.opacity(0.9))
                            Text("• 1,000,000 рублей (вопрос 15)")
                                .foregroundStyle(.white.opacity(0.9))
                        }
                        .padding(.top, 10)
                        
                        Text("Если вы ошибетесь, то получите последнюю несгораемую сумму. У вас есть 30 секунд на каждый ответ и три подсказки на всю игру.")
                            .font(.body)
                            .foregroundStyle(.white.opacity(0.9))
                            .padding(.top, 10)
                        
                        Spacer(minLength: 50)
                    }
                    .padding(20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Rules")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
            }
        }
    }
}
