//
//  GameSession.swift
//  Millionaire
//
//  Created by Effin Leffin on 22.07.2025.
//

import Foundation

/// enum с результатом ответа "правильно", "неправильно"
enum AnswerResult {
    case correct
    case incorrect
}

/// Состояние игры
struct GameSession: Hashable {
    /// Массив вопросов
    let questions: [Question]
    
    /// Флаг, указывающий, завершена игра или нет
    private(set) var isFinished: Bool
    /// Индекс текущего вопроса
    private(set) var currentQuestionIndex: Int
    /// Заработанный счет
    private(set) var score: Int
    /// Доступные подсказки
    private(set) var lifelines: Set<Lifeline>
    
    /// Tекущий вопрос
    var currentQuestion: Question {
        // Получаем текущий вопрос по индексу
        questions[currentQuestionIndex]
    }
    
    init?(
        questions: [Question],
        isFinished: Bool = false,
        currentQuestionIndex: Int = 0,
        score: Int = 0,
        lifelines: Set<Lifeline> = [.fiftyFifty, .callToFriend, .audience]
    ) {
        // Проверяем корректное количество вопросов в массиве questions
        // Проверяем, входит ли индекс текущего вопроса в диапазон
        // Если нет, инициализации не произойдет, игровая сессия не создастся
        guard
            questions.count == 15,
            0..<15 ~= currentQuestionIndex
        else {
            return nil
        }
        
        // Если все правильно, инициализируем
        self.questions = questions
        self.isFinished = isFinished
        self.currentQuestionIndex = currentQuestionIndex
        self.score = score
        self.lifelines = lifelines
    }
    
    /// Функция, возвращающая результат, был ответ верный или нет
    mutating func answer(answer: String) -> AnswerResult? {
        // Проверяем, что игра не закончена
        guard !isFinished else {
            return nil
        }
        
        // Убеждаемся, что ответ правильный
        if answer == currentQuestion.correctAnswer {
            // Увеличиваем счет на цену текущего вопроса. Цену берем из ScoreLogic по индексу текущего вопроса.
            score += ScoreLogic.questionValues[currentQuestionIndex]
            
            // Проверяем, есть ли следующий вопрос
            let hasNextQuestion = currentQuestionIndex + 1 < questions.count
            
            // Если да, увеличиваем индекс текущего вопроса, иначе заканчиваем игру
            if hasNextQuestion {
                currentQuestionIndex += 1
            } else {
                isFinished = true
            }
            
            // Возвращаем результат о том, что ответ был верный
            return .correct
        } else {
            // Если ответ неверный, в счет записываем несгораемую сумму.
            // Заканчиваем игру и возращаем результат о том, что был дан неверный ответ
            score = ScoreLogic.findClosestCheckpointScoreIndex(questionIndex: currentQuestionIndex)
            isFinished = true
            return .incorrect
        }
    }
    
    /// Метод "использоватьПодсказку"
    mutating func useLifeline(lifeline: Lifeline) {
        guard !isFinished else {
            return
        }
        
        // Из множества доступных подсказок убирается использованная, если такая есть
        if lifelines.contains(lifeline) {
            lifelines.remove(lifeline)
        } else {
            return
        }
    }
}
