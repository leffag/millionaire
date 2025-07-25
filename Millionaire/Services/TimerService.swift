//
//  TimerService.swift
//  Millionaire
//
//  Created by Келлер Дмитрий on 25.07.2025.
//

import Foundation
import Combine

// MARK: - Protocol

protocol ITimeManager {
    var progressPublisher: Published<Float>.Publisher { get }

    func start30SecondTimer(completion: @escaping () -> Void)
    func stop30SecondTimer()

    func start5SecondTimer(completion: @escaping () -> Void)
    func stop5SecondTimer()

    func start2SecondTimer(completion: @escaping () -> Void)
    func stopAllTimers()
}

// MARK: - Implementation

final class TimeManager: ITimeManager {

    // MARK: - Published Properties

    @Published private(set) var progress: Float = 0.0
    var progressPublisher: Published<Float>.Publisher { $progress }

    // MARK: - Timers

    private var timer30: Timer?
    private var timer5: Timer?
    private var timer2: Timer?

    // MARK: - State

    private var elapsed30 = 0
    private var elapsed5 = 0
    private var elapsed2 = 0

    private let total30 = 30

    // MARK: - Completion Handlers

    private var onComplete30: (() -> Void)?
    private var onComplete5: (() -> Void)?
    private var onComplete2: (() -> Void)?

    // MARK: - Init

    init() {}

    // MARK: - Public API

    func start30SecondTimer(completion: @escaping () -> Void) {
        onComplete30 = completion
        reset30()
        timer30 = Timer.scheduledTimer(timeInterval: 1.0,
                                       target: self,
                                       selector: #selector(update30),
                                       userInfo: nil,
                                       repeats: true)
    }

    func stop30SecondTimer() {
        timer30?.invalidate()
        timer30 = nil
    }

    func start5SecondTimer(completion: @escaping () -> Void) {
        onComplete5 = completion
        elapsed5 = 0
        timer5 = Timer.scheduledTimer(timeInterval: 1.0,
                                      target: self,
                                      selector: #selector(update5),
                                      userInfo: nil,
                                      repeats: true)
    }

    func stop5SecondTimer() {
        timer5?.invalidate()
        timer5 = nil
        elapsed5 = 0
    }

    func start2SecondTimer(completion: @escaping () -> Void) {
        onComplete2 = completion
        elapsed2 = 0
        timer2 = Timer.scheduledTimer(timeInterval: 1.0,
                                      target: self,
                                      selector: #selector(update2),
                                      userInfo: nil,
                                      repeats: true)
    }

    func stopAllTimers() {
        stop30SecondTimer()
        stop5SecondTimer()
        timer2?.invalidate()
        timer2 = nil
    }

    // MARK: - Private Helpers

    private func reset30() {
        elapsed30 = 0
        progress = 0
    }

    // MARK: - Timer Selectors

    @objc private func update30() {
        elapsed30 += 1
        progress = Float(elapsed30) / Float(total30)

        if elapsed30 >= total30 {
            stop30SecondTimer()
            onComplete30?()
        }
    }

    @objc private func update5() {
        elapsed5 += 1
        if elapsed5 >= 5 {
            stop5SecondTimer()
            onComplete5?()
        }
    }

    @objc private func update2() {
        elapsed2 += 1
        if elapsed2 >= 2 {
            timer2?.invalidate()
            timer2 = nil
            onComplete2?()
        }
    }
}
