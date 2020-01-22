//
//  AudioSessionEvent.swift
//  
//
//  Created by Ian Sampson on 2020-01-22.
//

import AVFoundation


// MARK: - Audio session event

extension AVAudioSession {
    enum Event {
        case interruption(type: AVAudioSession.InterruptionType, options: AVAudioSession.InterruptionOptions)
        case routeChange(reason: AVAudioSession.RouteChangeReason)
        case mediaReset
    }
}


// MARK: - Extensions

extension AVAudioSession.Event {
    var category: Category {
        switch self {
        case .interruption(_, _):
            return .interruption
        case .routeChange(_):
            return .routeChange
        case .mediaReset:
            return  .mediaReset
        }
    }
}

extension AVAudioSession.Event: Equatable {
    static func == (lhs: AVAudioSession.Event, rhs: AVAudioSession.Event) -> Bool {
        switch lhs {
        case let .interruption(lhsType, lhsOptions):
            if case let .interruption(rhsType, rhsOptions) = rhs {
                return lhsType == rhsType && rhsOptions == lhsOptions
            }
            
        case let .routeChange(reason: lhsReason):
            if case let .routeChange(rhsReason) = rhs {
                return lhsReason == rhsReason
            }
            
        case .mediaReset:
            if case .mediaReset = rhs {
                return true
            }
        }
        return false
    }
}

extension AVAudioSession.Event {
    init?(notification: Notification) {
        // TODO: Throw errors instead of failing the initializer.
        guard
            let category = Category(notification: notification),
            let info = Info(notification: notification)
        else {
            return nil
        }
        
        switch category {
        case .interruption:
            guard let type = info.interruptionType else { return nil }
            let options = info.interruptionOptions ?? []
            self = .interruption(type: type, options: options)
            
        case .routeChange:
            guard let reason = info.routeChangeReason else { return nil }
            self = .routeChange(reason: reason)
        
        case .mediaReset:
            self = .mediaReset
        }
    }
}
