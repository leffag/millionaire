//
//  FontChecker.swift
//  Millionaire
//
//  Created by Aleksandr Meshchenko on 23.07.25.
//



import SwiftUI
import UIKit

// MARK: - Font Checker Utility

struct FontChecker {
    
    /// Проверяет доступность конкретного шрифта
    static func isFontAvailable(_ fontName: String) -> Bool {
        return UIFont(name: fontName, size: 12) != nil
    }
    
    /// Возвращает все доступные шрифты в системе
    static func getAllAvailableFonts() -> [String] {
        return UIFont.familyNames.sorted()
    }
    
    /// Возвращает все варианты конкретного семейства шрифтов
    static func getFontVariants(for familyName: String) -> [String] {
        return UIFont.fontNames(forFamilyName: familyName).sorted()
    }
    
    /// Ищет шрифты, содержащие определенное слово
    static func searchFonts(containing searchTerm: String) -> [String] {
        let allFonts = UIFont.familyNames.flatMap { UIFont.fontNames(forFamilyName: $0) }
        return allFonts.filter { $0.localizedCaseInsensitiveContains(searchTerm) }.sorted()
    }
    
    /// Печатает информацию о SF шрифтах в консоль
    static func printSFFonts() {
        print("=== SF FONTS AVAILABLE ===")
        let sfFonts = searchFonts(containing: "SF")
        for font in sfFonts {
            print("✅ \(font)")
        }
        
        if sfFonts.isEmpty {
            print("❌ No SF fonts found")
        }
        
        print("\n=== SYSTEM FONTS ===")
        let systemFonts = searchFonts(containing: "System")
        for font in systemFonts {
            print("✅ \(font)")
        }
    }
}

// MARK: - Font Preview Component

struct FontPreview: View {
    
    @State private var availableFonts: [String] = []
    @State private var sfFonts: [String] = []
    @State private var isCompactDisplayAvailable = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Проверка SF Compact Display
                VStack(alignment: .leading, spacing: 10) {
                    Text("SF Compact Display Check")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        Image(systemName: isCompactDisplayAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(isCompactDisplayAvailable ? .green : .red)
                        
                        Text(isCompactDisplayAvailable ? 
                             "SF Compact Display доступен ✅" : 
                             "SF Compact Display НЕ найден ❌")
                            .foregroundColor(isCompactDisplayAvailable ? .green : .red)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // Тест разных вариантов SF
                VStack(alignment: .leading, spacing: 15) {
                    Text("Font Tests")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // SF Compact Display
                    VStack(alignment: .leading, spacing: 5) {
                        Text("SF Compact Display:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("Кто хочет стать миллионером? ABC 123")
                            .font(.custom("SF Compact Display", size: 20))
                    }
                    
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
                
                // Список найденных SF шрифтов
                if !sfFonts.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Найденные SF шрифты:")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        ForEach(sfFonts, id: \.self) { fontName in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(fontName)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("Sample Text 123")
                                    .font(.custom(fontName, size: 16))
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .onAppear {
            checkFonts()
        }
    }
    
    private func checkFonts() {
        // Проверяем SF Compact Display
        isCompactDisplayAvailable = FontChecker.isFontAvailable("SF Compact Display")
        
        // Ищем все SF шрифты
        sfFonts = FontChecker.searchFonts(containing: "SF")
        
        // Печатаем в консоль для отладки
        FontChecker.printSFFonts()
        
        print("\n=== COMPACT DISPLAY CHECK ===")
        print("SF Compact Display available: \(isCompactDisplayAvailable)")
    }
}

// MARK: - Preview

#Preview("Font Checker") {
    FontPreview()
}
