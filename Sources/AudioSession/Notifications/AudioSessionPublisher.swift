//
//  AudioSessionPublisher.swift
//  
//
//  Created by Ian Sampson on 2020-01-22.
//

import AVFoundation
import Combine


extension AVAudioSession {
    typealias Publisher = AnyPublisher<AVAudioSession.Event, Never>
    // TODO: Handle failure.
    
    var publisher: Publisher {
        publisher(notificationCenter: .default)
    }
    
    func publisher(notificationCenter: NotificationCenter) -> Publisher {
        publisher(for: .interruption, notificationCenter: notificationCenter)
        .merge(with:
            publisher(for: .routeChange, notificationCenter: notificationCenter),
            publisher(for: .mediaReset, notificationCenter: notificationCenter)
        )
        .eraseToAnyPublisher()
    }
    
    private func publisher(for event: Event.Category, notificationCenter: NotificationCenter) -> AnyPublisher<AVAudioSession.Event, Never> {
        // TODO: Make name-spacing consistent.
        
        // Subscribe for audio session notifications.
        notificationCenter
            .publisher(for: event.notificationName)
            .filter {
                // Make sure the notification matches this audio session.
                $0.object as? AVAudioSession === self
            }
            .compactMap {
                // Convert the notification into a type-safe event.
                Event(notification: $0)
                // TODO: Handle errors instead of returning nil.
            }
            .eraseToAnyPublisher()
    }
}
