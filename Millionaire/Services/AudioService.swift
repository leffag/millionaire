//
//  IAudioService.swift
//  Millionaire
//
//  Created by Келлер Дмитрий on 25.07.2025.
//


import AVFoundation

protocol IAudioService {
    func playGameSfx()
    func playWrongAnswerSfx()
    func playCorrectAnswerSfx()
    func playAnswerLockedSfx()
    func stop()
}

final class AudioService: IAudioService {

    enum ResourceSfx: String {
        case gameSfx
        case wrongAnswerSfx
        case correctAnswerSfx
        case answerLockedSfx
    }
    
    private var player: AVAudioPlayer?

    private func play(resource: ResourceSfx) {
        guard let url = Bundle.main.url(forResource: resource.rawValue, withExtension: "mp3") else {
            print("Audio resource not found: \(resource.rawValue)")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Failed to play audio: \(error.localizedDescription)")
        }
    }

    // MARK: - Public Methods
    func playGameSfx() {
        play(resource: .gameSfx)
    }
    
    func playWrongAnswerSfx() {
        play(resource: .wrongAnswerSfx)
    }
    
    func playCorrectAnswerSfx() {
        play(resource: .correctAnswerSfx)
    }
    
    func playAnswerLockedSfx() {
        play(resource: .answerLockedSfx)
    }
    
    func stop() {
        player?.stop()
        player = nil
    }
}
