import Foundation
import GraphmastersNavigationCore
import XCTest

final class AccessFrameworkTests: XCTestCase {
    func testAccess() {
        XCTAssertEqual(GraphmastersNavigationCore().frameworkName, "GraphmastersNavigationCore")
    }
}
