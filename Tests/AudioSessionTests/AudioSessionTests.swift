import XCTest
@testable import AudioSession

final class AudioSessionTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(AudioSession().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
