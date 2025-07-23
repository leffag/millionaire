//
//  GameViewModel.swift
//  Millionaire
//
//  Created by Келлер Дмитрий on 22.07.2025.
//

import Foundation

final class GameViewModel: ObservableObject {
    let networkService: NetworkService
    
    let duration: String = "00:00"
    
    @Published var question: Question? = nil
    
    @Published var answers: [Answer] = []
    @Published var selectedAnswer: Answer?
    @Published var answerStates: [UUID:AnswerState] = [:]
    
    let difficult: QuestionDifficulty = .easy
    let numberQuestion = 0
    let priceQuestion: String = "100"

    
//    MARK: Init
    init(networkService: NetworkService = .shared) {
        self.networkService = networkService
        startGame()
    }
    
    // MARK: - Game State
    func startGame() {
        let mockQuestion = Question(
            difficulty: .easy,
            category: "General Knowledge",
            question: "What is the capital of France?",
            correctAnswer: "Paris",
            incorrectAnswers: ["London", "Berlin", "Madrid"]
        )
        
        question = mockQuestion
        if let question = question {
            prepareAnwers(for: question)
            
        }
    }
    
    func stopGame() {
        
    }
    
    func gameOver() {
        
    }
    
    func selectAnswer(_ answer: Answer) {
       
        selectedAnswer = answer
        
        Task {
            await MainActor.run { [weak self] in
                self?.answerStates[answer.id] = .selected
            }
            try? await Task.sleep(nanoseconds: 5 * 1_000_000_000)
            
            await MainActor.run {
                for ans in self.answers {
                    if ans.id == answer.id {
                        self.answerStates[ans.id] = ans.isCorrect ? .correct : .incorrect
                    } else if ans.isCorrect {
                        self.answerStates[ans.id] = .correct
                    }
                }
            }
        }
    }
    
    // MARK: - Help Button Actions
    func fiftyFiftyButtonTap() {
        
    }
    
    func audienceButtonTap() {
        
    }
    
    func callYourFriendButtonTap() {
        
    }
    
    private func prepareAnwers(for question: Question) {
        answerStates = Dictionary(uniqueKeysWithValues: answers.map {($0.id, .normal)})
        var allAnswers = question.incorrectAnswers.map { Answer(text: $0, isCorrect: false) }
        allAnswers.append(Answer(text: question.correctAnswer, isCorrect: true))
        answers = allAnswers.shuffled()
    }
}
