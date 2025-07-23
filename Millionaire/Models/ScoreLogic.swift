//
//  ScoreLogic.swift
//  Millionaire
//
//  Created by Effin Leffin on 23.07.2025.
//

import Foundation

enum ScoreLogic {
    static let questionValues: [Int] = [
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
    
    static let checkpointIndices: [Int] = [4, 9, 14]
    
    static func findClosestCheckpointScoreIndex(questionIndex: Int) -> Int {
        let checkpointIndex = checkpointIndices.last { $0 < questionIndex }
        
        if let checkpointIndex {
            return questionValues[checkpointIndex]
        }
        else {
            return 0
        }
    }
}
