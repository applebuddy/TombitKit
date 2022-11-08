import XCTest
@testable import TombitKit

final class TombitKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(TombitKit().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
