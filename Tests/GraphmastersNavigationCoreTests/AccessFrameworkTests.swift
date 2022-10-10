import Foundation
import XCTest
import GraphmastersNavigationCore

final class AccessFrameworkTests: XCTestCase {
    func testAccess() {
        XCTAssertEqual(GraphmastersNavigationCore().frameworkName, "GraphmastersNavigationCore")
    }
}
