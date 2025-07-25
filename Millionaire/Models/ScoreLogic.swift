//
//  ScoreLogic.swift
//  Millionaire
//
//  Created by Effin Leffin on 23.07.2025.
//

import Foundation

/// Логика подсчета текущего счета
enum ScoreLogic {
    /// Массив с ценой каждого вопроса
    static let questionValues: [Int] = [
        500,
        1000,
        2000,
        3000,
        5000,
        7500,
        10000,
        12500,
        15000,
        25000,
        50000,
        100000,
        250000,
        500000,
        1000000
    ]
    
    /// Массив с индексами "чекпоинтов". Соответствуют индексу вопроса с несгораемой суммой
    static let checkpointIndices: [Int] = [5, 10, 15]
    
    /// Метод найтиБлижайшийИндексЧекпоинта
    /// Возвращает несгораемую сумму, либо 0, если до вопросов с несгораемой суммой не дошли.
    static func findClosestCheckpointScore(questionIndex: Int) -> Int {
        // Проверяем, были ли вопросы с несгораемой суммой до вопроса с индексом.
        let checkpointIndex = checkpointIndices.last { $0 < questionIndex }
        
        // Если да, возвращаем вознаграждение сооответствующее чекпоинту, либо 0, если чекпоинта нет.
        if let checkpointIndex {
            return questionValues[checkpointIndex]
        }
        else {
            return 0
        }
    }
}
