//
//  MillionaireButtonStyle.swift
//  Millionaire
//
//  Created by Aleksandr Meshchenko on 22.07.25.
//
import SwiftUI

// MARK: - Answer Button Content Model
struct AnswerButtonContent {
    let letter: String  // "A", "B", "C", "D"
    let text: String    // Текст ответа
}

// MARK: - Millionaire Button Style (Image-Based Only)

/// Кастомный стиль кнопки для игры "Кто хочет стать миллионером?"
/// Использует только изображения как основу с дополнительными эффектами
struct MillionaireButtonStyle: ButtonStyle {
    
    // MARK: - Properties
    
    let variant: Variant
    let answerContent: AnswerButtonContent?
    @Environment(\.isEnabled) private var isEnabled
    
    // MARK: - Initialization
    
    init(variant: Variant = .primary,
         answerContent: AnswerButtonContent? = nil) {
        self.variant = variant
        self.answerContent = answerContent
    }
    
    // MARK: - ButtonStyle Implementation
    
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // Фон на основе изображения
            imageBackground(for: configuration)
            
            // Контент кнопки
            if let answerContent = answerContent, variant.isAnswerButton {
                // Специальная разметка для кнопок ответов
                answerButtonContent(answerContent)
            } else {
                // Обычный контент для других кнопок
                configuration.label
                    .font(.millionaireMenuButton) // Используем кастомный шрифт
                    .fontWeight(.semibold)
                    .foregroundColor(textColor)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
            }
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
    
    @ViewBuilder
    private func answerButtonContent(_ content: AnswerButtonContent) -> some View {
        HStack(alignment: .center) {
            // Первая строка - желтая буква (A, B, C, D)
            Text(content.letter)
                .millionaireAnswerLetterStyle()
                .padding(.leading, 24)
            
            // Вторая строка - белый текст ответа
            Text(content.text)
                .millionaireAnswerTextStyle()
                .multilineTextAlignment(.leading)
                .padding(.leading, 10)
            
            Spacer()
        }
        
        .frame(maxWidth: .infinity)
        .padding()
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
        
        var isAnswerButton: Bool {
            switch self {
            case .answerRegular, .answerCorrect, .answerWrong:
                return true
            case .primary, .regular:
                return false
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
            MillionaireButtonStyle(variant: variant)
        )
    }
    
    /// Применяет стиль кнопки ответа с двухстрочным текстом
    func millionaireAnswerStyle(
        _ variant: MillionaireButtonStyle.Variant,
        letter: String,
        answerText: String,
        isEnabled: Bool = true
    ) -> some View {
        self.buttonStyle(
            MillionaireButtonStyle(
                variant: variant,
                answerContent: AnswerButtonContent(letter: letter, text: answerText)
            )
        )
    }
}

// MARK: - Preview

#Preview("Button Variants with Images") {
    VStack(spacing: 20) {
        
        // Заголовок с кастомным шрифтом
        Text("Кто хочет стать миллионером?")
            .millionaireTitleStyle()
        
        // Главное меню
        Button("Primary Button") { }
            .millionaireStyle(.primary)
        
        Button("Regular Button") { }
            .millionaireStyle(.regular)
        
        // Кнопки ответов
        VStack(spacing: 10) {
            Text("Answer Buttons:")
                .millionaireQuestionStyle()
            
            Button {} label: {
                EmptyView()
            }
            .millionaireAnswerStyle(.answerRegular, letter: "A:", answerText: "Правильный ответ на вопрос")
            
            Button {} label: {
                EmptyView()
            }
            .millionaireAnswerStyle(.answerCorrect, letter: "B:", answerText: "Это правильный ответ")
            
            Button {} label: {
                EmptyView()
            }
            .millionaireAnswerStyle(.answerWrong, letter: "C:", answerText: "Неправильный вариант")
            
            Button {} label: {
                EmptyView()
            }
            .millionaireAnswerStyle(.answerRegular, letter: "D:", answerText: "Еще один вариант ответа")
        }
        // Дополнительные элементы с кастомными шрифтами
        HStack {
            Text("Таймер: 30")
                .millionaireTimerStyle()
            
            Spacer()
            
            Text("32,000 руб.")
                .millionairePrizeStyle(isActive: true)
        }
        .padding(.horizontal)
        
        // Отключенная кнопка через disabled(_:)
        Button("Disabled Button") { }
            .millionaireStyle(.primary, isEnabled: false)
            .disabled(true) // Используем стандартный SwiftUI API!
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
