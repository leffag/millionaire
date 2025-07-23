//
//  TimerMusicService.swift
//  Millionaire
//
//  Created by Келлер Дмитрий on 22.07.2025.
//

import Foundation


final class TimerService {
    private var timer: Timer?
    private var secondsRemaining: Int = 0
    private var callback: (() -> Void)?

    func start(seconds: Int, onTimeout: @escaping () -> Void) {
        secondsRemaining = seconds
        callback = onTimeout
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            secondsRemaining -= 1
            if secondsRemaining <= 0 {
                stop()
                onTimeout()
            }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
