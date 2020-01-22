//
//  AudioNotificationEvent.swift
//  
//
//  Created by Ian Sampson on 2020-01-21.
//

import AVFoundation


enum AudioNotification {
    case interruption(type: AVAudioSession.InterruptionType, options: AVAudioSession.InterruptionOptions)
    case routeChange(reason: AVAudioSession.RouteChangeReason)
    case mediaReset
}

extension AudioNotification {
    static func interruption(_ notification: Notification) -> AudioNotification? {
        guard
            let info = AudioSessionNotificationInfo(notification: notification),
            let type = info.interruptionType
        else {
            return nil
            // TODO: Throw error instead.
        }
        let options = info.interruptionOptions ?? []
        return .interruption(type: type, options: options)
    }
    
    static func routeChange(_ notification: Notification) -> AudioNotification? {
        guard
            let info = AudioSessionNotificationInfo(notification: notification),
            let reason = info.routeChangeReason
        else {
            return nil
            // TODO: Throw error instead.
        }
        return .routeChange(reason: reason)
    }
}
