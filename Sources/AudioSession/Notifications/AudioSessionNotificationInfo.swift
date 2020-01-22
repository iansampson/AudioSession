//
//  AudioInterruption.swift
//  
//
//  Created by Ian Sampson on 2019-02-02.
//

import AVFoundation


// MARK: - Notification info key

extension AVAudioSession.Event {
    enum InfoKey {
        case interruptionType
        case interruptionOptions
        case routeChangeReason
    }
}

extension AVAudioSession.Event.InfoKey {
    var string: String {
        switch self {
        case .interruptionType:
            return AVAudioSessionInterruptionTypeKey
        case .interruptionOptions:
            return AVAudioSessionInterruptionOptionKey
        case .routeChangeReason:
            return AVAudioSessionRouteChangeReasonKey
        }
    }
}


// MARK: - Notification info

extension AVAudioSession.Event{
    struct Info {
        private let info: [AnyHashable: Any]
        
        init?(notification: Notification) {
            guard let info = notification.userInfo else {
                return nil
            }
            self.info = info
        }
        // TODO: Throw error instead of failing initializer.
    }
}

extension AVAudioSession.Event.Info {
    private func rawValue(for key: AVAudioSession.Event.InfoKey) -> UInt? {
        guard let any = info[key.string] else { return nil }
        guard let value = any as? UInt else { fatalError() }
        return value
    }
    // TODO: Consider throwing error instead of terminating.
    
    var interruptionType: AVAudioSession.InterruptionType? {
        guard let value = rawValue(for: .interruptionType) else { return nil }
        return AVAudioSession.InterruptionType(rawValue: value)
    }
    
    var interruptionOptions: AVAudioSession.InterruptionOptions? {
        guard let value = rawValue(for: .interruptionOptions) else { return nil }
        return AVAudioSession.InterruptionOptions(rawValue: value)
    }
    
    var routeChangeReason: AVAudioSession.RouteChangeReason? {
        guard let value = rawValue(for: .routeChangeReason) else { return nil }
        return AVAudioSession.RouteChangeReason(rawValue: value)
    }
}
