import AVFoundation
import Combine
import XCTest
@testable import AudioSession


// MARK: - Tests

final class AudioSessionTests: XCTestCase {
    var subscribers = [AnyCancellable]()
    
    func testAudioInterrupted() {
        // Construct user info for notification.
        let userInfo = [
            AVAudioSessionInterruptionTypeKey: NSNumber(
                value: AVAudioSession.InterruptionType.began.rawValue
            )
        ]
        
        // Post notification and compare result.
        postNotificationAndCompareResult(
            notificationName: AVAudioSession.interruptionNotification,
            userInfo: userInfo,
            expectedEvent: .interruption(type: .began, options: [])
        )
    }
    
    func testRouteChange() {
        // Construct user info for notification.
        let userInfo = [
            AVAudioSessionRouteChangeReasonKey: NSNumber(
                value: AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue
            )
        ]
        
        // Post notification and compare result.
        postNotificationAndCompareResult(
            notificationName: AVAudioSession.routeChangeNotification,
            userInfo: userInfo,
            expectedEvent: .routeChange(reason: .oldDeviceUnavailable)
        )
    }
    
    func testMediaServicesReset() {
        // Post notification and compare result.
        postNotificationAndCompareResult(
            notificationName: AVAudioSession.mediaServicesWereResetNotification,
            userInfo: [:],
            expectedEvent: .mediaServicesReset
        )
    }
    // TODO: Handle case where user info is nil.
    
    static var allTests = [
        ("testAudioInterrupted", testAudioInterrupted),
        ("testRouteChange", testRouteChange),
        ("testMediaServicesReset", testMediaServicesReset)
    ]
}


// MARK: - Extensions

private extension AudioSessionTests {
    
    // Post notification and subscribe to events.
    // Pass test only if the received event matches the expected event.
    private func postNotificationAndCompareResult(
        notificationName: Notification.Name,
        userInfo: [AnyHashable : Any],
        expectedEvent: AVAudioSession.Event
    ) {
        // Create expectation.
        let expectation = XCTestExpectation(description: expectedEvent.category.description)
        
        // Post notification and subscribe to events.
        postNotificationAndSubscribeToAudioSession(
            notificationName: notificationName,
            userInfo: userInfo
        ) {
            // Compare actual event to expected event.
            XCTAssertEqual($0, expectedEvent)
            
            // Fulfill expectation.
            expectation.fulfill()
        }
        
        // Wait for expectation to be fulfilled.
        wait(for: [expectation], timeout: 2)
    }
    
    // Post notification and subscribe to events.
    private func postNotificationAndSubscribeToAudioSession(notificationName: Notification.Name, userInfo: [AnyHashable : Any]?, handler: @escaping (AVAudioSession.Event) -> Void) {
        // Construct audio session and notification center.
        let audioSession = AVAudioSession()
        let notificationCenter = NotificationCenter()
        
        // Subscribe to audio session.
        let subscriber = audioSession
            .publisher(notificationCenter: notificationCenter)
            .sink {
                handler($0)
            }
        subscribers.append(subscriber)
        
        // Post notification.
        let notification = Notification(name: notificationName, object: audioSession, userInfo: userInfo)
        notificationCenter.post(notification)
    }
}
