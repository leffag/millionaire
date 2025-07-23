//
//  ScoreLogic.swift
//  Millionaire
//
//  Created by Effin Leffin on 23.07.2025.
//

import Foundation

struct ScoreLogic {
    static var questionValues: [Int] = [
        100,
        100,
        100,
        200,
        500,
        1000,
        2000,
        4000,
        8000,
        16000,
        32000,
        61000,
        125000,
        250000,
        500000
    ]
    
    static var checkpointIndices: [Int] = [4, 9, 14]
    
    static func findClosestCheckpointScore(questionIndex: Int) -> Int {
        return checkpointIndices.last { $0 < questionIndex } ?? 0
    }
}
