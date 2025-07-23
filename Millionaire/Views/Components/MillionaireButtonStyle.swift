//
//  MillionaireButtonStyle.swift
//  Millionaire
//
//  Created by Aleksandr Meshchenko on 22.07.25.
//
import SwiftUI

// MARK: - Millionaire Button Style (Image-Based Only)

/// Кастомный стиль кнопки для игры "Кто хочет стать миллионером?"
/// Использует только изображения как основу с дополнительными эффектами
struct MillionaireButtonStyle: ButtonStyle {
    
    // MARK: - Properties
    
    let variant: Variant
    let isEnabled: Bool
    
    // MARK: - Initialization
    
    init(variant: Variant = .primary, isEnabled: Bool = true) {
        self.variant = variant
        self.isEnabled = isEnabled
    }
    
    // MARK: - ButtonStyle Implementation
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // Фон на основе изображения
            imageBackground(for: configuration)
            
            // Контент кнопки
            configuration.label
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(textColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .opacity(isEnabled ? 1.0 : 0.6)
        .shadow(
            color: shadowColor.opacity(shadowOpacity(for: configuration)),
            radius: shadowRadius(for: configuration),
            x: 0,
            y: shadowOffset(for: configuration)
        )
        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
        .disabled(!isEnabled)
    }
    
    // MARK: - Private Methods
    
    @ViewBuilder
    private func imageBackground(for configuration: Configuration) -> some View {
        Image(variant.imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 60)
            .overlay(
                // Блеск при взаимодействии
                LinearGradient(
                    colors: configuration.isPressed ? [] : [
                        Color.white.opacity(0.0),
                        Color.white.opacity(0.1),
                        Color.white.opacity(0.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
    
    private var textColor: Color {
        return isEnabled ? .white : Color.white.opacity(0.5)
    }
    
    private var shadowColor: Color {
        switch variant {
        case .primary:
            return .yellow
        case .regular:
            return .blue
        case .answerRegular:
            return Color(red: 0.2, green: 0.4, blue: 0.8)
        case .answerCorrect:
            return .green
        case .answerWrong:
            return .red
        }
    }
    
    private func shadowOpacity(for configuration: Configuration) -> Double {
        if !isEnabled { return 0.2 }
        return configuration.isPressed ? 0.8 : 0.6
    }
    
    private func shadowRadius(for configuration: Configuration) -> CGFloat {
        if !isEnabled { return 4 }
        return configuration.isPressed ? 12 : 8
    }
    
    private func shadowOffset(for configuration: Configuration) -> CGFloat {
        if !isEnabled { return 2 }
        return configuration.isPressed ? 6 : 4
    }
}

// MARK: - Button Variant

extension MillionaireButtonStyle {
    
    /// Варианты стилей кнопки (только изображения)
    enum Variant {
        case primary        // Основная кнопка (золотистая)
        case regular        // Обычная кнопка (синяя)
        case answerRegular  // Обычный ответ (не выбран)
        case answerCorrect  // Правильный ответ (зеленый)
        case answerWrong    // Неправильный ответ (красный)
        
        /// Название изображения для фона
        var imageName: String {
            switch self {
            case .primary:
                return "PrimaryButton"
            case .regular:
                return "RegularButton"
            case .answerRegular:
                return "AnswerRegular"
            case .answerCorrect:
                return "AnswerCorrect"
            case .answerWrong:
                return "AnswerWrong"
            }
        }
    }
}

// MARK: - Convenience Extensions

extension Button {
    
    /// Применяет стиль кнопки миллионера с изображениями
    func millionaireStyle(
        _ variant: MillionaireButtonStyle.Variant = .primary,
        isEnabled: Bool = true
    ) -> some View {
        self.buttonStyle(
            MillionaireButtonStyle(
                variant: variant,
                isEnabled: isEnabled
            )
        )
    }
}

// MARK: - Preview

#Preview("Button Variants with Images") {
    VStack(spacing: 20) {
        // Главное меню
        Button("Primary Button") { }
            .millionaireStyle(.primary)
        
        Button("Regular Button") { }
            .millionaireStyle(.regular)
        
        // Кнопки ответов
        VStack(spacing: 10) {
            Text("Answer Buttons:")
                .foregroundColor(.white)
                .font(.headline)
            
            Button("A) Regular Answer") { }
                .millionaireStyle(.answerRegular)
            
            Button("B) Correct Answer") { }
                .millionaireStyle(.answerCorrect)
            
            Button("C) Wrong Answer") { }
                .millionaireStyle(.answerWrong)
        }
        
        // Отключенная кнопка
        Button("Disabled Button") { }
            .millionaireStyle(.primary, isEnabled: false)
    }
    .padding()
    .background(
        LinearGradient(
            colors: [
                Color(red: 0.063, green: 0.055, blue: 0.086),
                Color(red: 0.216, green: 0.298, blue: 0.58)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    )
}
