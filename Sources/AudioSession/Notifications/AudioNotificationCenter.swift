//
//  AudioNotificationCenter.swift
//  
//
//  Created by Ian Sampson on 2020-01-22.
//

import AVFoundation
import Combine


extension NotificationCenter {
    typealias AudioNotificationPublisher = AnyPublisher<AudioNotification, NotificationCenter.Publisher.Failure>
    // TODO: Consider replacing with a custom error type.
    
    var audioNotificationPublisher: AudioNotificationPublisher {
        let interruption = self
            .publisher(for: AVAudioSession.interruptionNotification)
            .compactMap {
                AudioNotification.interruption($0)
            }
        
        let routeChange = self
            .publisher(for: AVAudioSession.routeChangeNotification)
            .compactMap {
                AudioNotification.routeChange($0)
        }
        
        let mediaReset = self
            .publisher(for: AVAudioSession.mediaServicesWereResetNotification)
            .map { _ in
                AudioNotification.mediaReset
            }

        return interruption
            .merge(with: routeChange, mediaReset)
            .eraseToAnyPublisher()
    }
}

// TODO: Consider using separate publishers instead of this merged one.
// TODO: Or attaching one subscriber to multiple publishers, if that’s allowed.
