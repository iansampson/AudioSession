//
//  AudioSessionEventCategory.swift
//  
//
//  Created by Ian Sampson on 2020-01-22.
//

import AVFoundation


// MARK: - Audio session event category

extension AVAudioSession.Event {
    enum Category {
        case interruption
        case routeChange
        case mediaReset
        // TODO: Consider renaming to mediaServicesReset.
    }
}

extension AVAudioSession.Event.Category {
    var notificationName: Notification.Name {
        switch self  {
        case .interruption:
            return AVAudioSession.interruptionNotification
        case .routeChange:
            return AVAudioSession.routeChangeNotification
        case .mediaReset:
            return AVAudioSession.mediaServicesWereResetNotification
        // TODO: Handle media services lost notification.
        }
    }
    
    init?(notification: Notification) {
        switch notification.name {
        case Self.interruption.notificationName:
            self = .interruption
        case Self.routeChange.notificationName:
            self = .routeChange
        case Self.mediaReset.notificationName:
            self = .mediaReset
        default:
            return nil
        }
    }
}

extension AVAudioSession.Event.Category: CustomStringConvertible {
    var description: String {
        switch self {
        case .interruption:
            return "Interruption"
        case .routeChange:
            return "Route change"
        case .mediaReset:
            return "Media services reset"
        }
    }
}
