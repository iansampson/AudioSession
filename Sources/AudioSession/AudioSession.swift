//
//  AudioSession.swift
//
//
//  Created by Ian Sampson on 2020-01-21.
//

import AVFoundation
import Combine


// MARK: - Audio session

final class AudioSession {
    let publisher = PassthroughSubject<Event, Never>()
    var subscriber: AnyCancellable?
    // TODO: Make constant if possible.
    
    private let audioSession: AVAudioSession
    // TODO: Consider using unowned let.
    private var wasInterrupted = false
    var options: AVAudioSession.CategoryOptions {
        get {
            return audioSession.categoryOptions
        }
        set {
            do {
                try audioSession.setCategory(.playback, mode: .default, options: newValue)
            } catch {
                print(error.localizedDescription)
                // TODO: Handle errors.
            }
        }
    }
    
    init(
        audioSession: AVAudioSession,
        notificationCenter: NotificationCenter,
        options: AVAudioSession.CategoryOptions
    ) throws {
        self.audioSession = audioSession
        
        // Configure and activate audio session.
        try audioSession.setCategory(.playback, mode: .default, options: options)
        try audioSession.setActive(true)
        // TODO: Necessary? Playing audio should activate the session on its own.
        
        // Subscribe to notifications.
        let subscriber = audioSession
            .publisher(notificationCenter: notificationCenter)
            .sink {
                switch $0 {
                case .interruption(let type, let options):
                    self.handleInterruption(type: type, options: options)
                case .routeChange(let reason):
                    self.handleRouteChange(reason: reason)
                case .mediaReset:
                    self.handleMediaReset()
                }
            }
        
        self.subscriber = subscriber
    }
    
    // TODO: Necessary?
    deinit {
        do {
            try audioSession.setActive(false)
        } catch {
            print(error)
        }
    }
}


// MARK: Notifications

extension AudioSession {
    private func handleInterruption(type: AVAudioSession.InterruptionType, options: AVAudioSession.InterruptionOptions) {
        switch type {
        case .began:
            // If audio is playing.
            pauseAudio()
            self.wasInterrupted = true // TODO: Needed?
        case .ended:
            if self.wasInterrupted && options.contains(.shouldResume) {
                playAudio()
                wasInterrupted = false // TODO: Needed?
            }
        @unknown default:
            return
        }
    }
    
    private func handleRouteChange(reason: AVAudioSession.RouteChangeReason) {
        switch reason {
        case .oldDeviceUnavailable:
            pauseAudio()
        default:
            break
        // TODO: Handle other categories.
        }
    }
    
    private func handleMediaReset() {
        reset()
    }
}


// MARK: - Playback

extension AudioSession {
    enum Event {
        case played
        case paused
        case reset
    }
}

extension AudioSession.Event: CustomStringConvertible {
    var description: String {
        switch self {
        case .played:
            return "Audio session played."
        case .paused:
            return "Audio session paused."
        case .reset:
            return "Media services were reset."
        }
    }
}

extension AudioSession {
    private  func playAudio() {
        publisher.send(.played)
    }
    
    private func pauseAudio() {
        publisher.send(.paused)
    }
    
    private func reset() {
        publisher.send(.reset)
    }
}
