//
//  AnswerModel.swift
//  Millionaire
//
//  Created by Келлер Дмитрий on 23.07.2025.
//

import Foundation

struct Answer: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let isCorrect: Bool
}
