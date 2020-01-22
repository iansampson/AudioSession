import AVFoundation
import Combine
import XCTest
@testable import AudioSession


// MARK: - Tests

final class AudioSessionTests: XCTestCase {
    var subscribers = [AnyCancellable]()
    
    func testAudioInterrupted() {
        // Post notification and wait for expected result.
        let notification = Notification(
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance(),
            userInfo: [AVAudioSessionInterruptionTypeKey : NSNumber(
                value: AVAudioSession.InterruptionType.began.rawValue)
            ])
        postNotification(notification, expecting: .paused)
    }
    
    /*func testAudioResumed() {
        // Post notification and wait for expected result.
        let notification = Notification(
            name: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance(),
            userInfo: [AVAudioSessionInterruptionTypeKey : NSNumber(
                value: AVAudioSession.InterruptionType.ended.rawValue)
            ])
        postNotification(notification, expecting: .played)
    }*/
    
    func testOldDeviceUnavailable() {
        // Post notification and wait for expected result.
        let notification = Notification(
            name: AVAudioSession.routeChangeNotification,
            object: AVAudioSession.sharedInstance(),
            userInfo: [AVAudioSessionRouteChangeReasonKey : NSNumber(
                value: AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue
            )]
        )
        postNotification(notification, expecting: .paused)
    }
    
    func testNewDeviceAvailable() {
        // Post notification and wait for expected result.
        let notification = Notification(
            name: AVAudioSession.routeChangeNotification,
            object: AVAudioSession.sharedInstance(),
            userInfo: [AVAudioSessionRouteChangeReasonKey : NSNumber(
                value: AVAudioSession.RouteChangeReason.newDeviceAvailable.rawValue
            )]
        )
        postNotification(notification, expecting: nil)
    }
    
    func testMediaServicesReset() {
        // Post notification and wait for expected result.
        let notification = Notification(
            name: AVAudioSession.mediaServicesWereResetNotification,
            object: AVAudioSession.sharedInstance(),
            userInfo: [:]
        )
        postNotification(notification, expecting: .reset)
    }
    
    static var allTests = [
        ("testAudioInterrupted", testAudioInterrupted),
        //("testAudioResumed", testAudioResumed),
        ("testOldDeviceUnavailable", testOldDeviceUnavailable),
        ("testNewDeviceAvailable", testNewDeviceAvailable),
        ("testMediaServicesReset", testMediaServicesReset)
    ]
    
    // TODO: Test mixWithOthers.
}


// MARK: - Extensions

private extension AudioSessionTests {
    // Configure an audio session, post a notification, and wait for the expected result.
    func postNotification(_ notification: Notification, expecting expectedEvent: AudioSession.Event?) {
        // Create a new notification center to avoid conflicts with other tests.
        let notificationCenter = NotificationCenter()
        
        do {
            // Configure audio session.
            let audioSession = try AudioSession(
                audioSession: .sharedInstance(),
                notificationCenter: notificationCenter,
                options: []
            )
            
            // If audio session is expected to publish an event...
            if let expectedEvent = expectedEvent {
                // Configure expectation.
                let expectation = XCTestExpectation(description: expectedEvent.description)
                
                // Subscribe to changes in audio session.
                let subscriber = audioSession.publisher.sink { actualEvent in
                    XCTAssertEqual(actualEvent, expectedEvent)
                    expectation.fulfill()
                }
                subscribers.append(subscriber)
                
                // Post notification.
                notificationCenter.post(notification)
                
                // Wait for expectation to be fulfilled.
                wait(for: [expectation], timeout: 2)
                
            // If no event is expected...
            } else {
                // Subscribe to changes in audio session.
                let subscriber = audioSession.publisher.sink { actualEvent in
                    XCTFail()
                }
                subscribers.append(subscriber)
                
                // Post notification.
                notificationCenter.post(notification)
            }

        } catch {
            print(error.localizedDescription)
            XCTFail()
        }
    }
}
