//
//  AudioSessionPublisher.swift
//  
//
//  Created by Ian Sampson on 2020-01-22.
//

import AVFoundation
import Combine


extension AVAudioSession {
    public typealias Publisher = AnyPublisher<AVAudioSession.Event, Never>
    // TODO: Handle failure.
    
    public var publisher: Publisher {
        publisher(notificationCenter: .default)
    }
    
    public func publisher(notificationCenter: NotificationCenter) -> Publisher {
        publisher(for: .interruption, notificationCenter: notificationCenter)
        .merge(with:
            publisher(for: .routeChange, notificationCenter: notificationCenter),
            publisher(for: .mediaServicesReset, notificationCenter: notificationCenter)
        )
        .eraseToAnyPublisher()
    }
    
    private func publisher(for event: Event.Category, notificationCenter: NotificationCenter) -> AnyPublisher<AVAudioSession.Event, Never> {
        // Subscribe for audio session notifications.
        notificationCenter
            .publisher(for: event.notificationName, object: self)
            .compactMap {
                // Convert the notification into a type-safe event.
                Event(notification: $0)
                // TODO: Handle errors instead of returning nil.
            }
            .eraseToAnyPublisher()
    }
}
