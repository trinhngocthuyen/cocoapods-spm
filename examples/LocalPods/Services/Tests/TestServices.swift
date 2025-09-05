import XCTest
import SwiftyBeaver
import DebugKit
@testable import Services

final class ServiceTests: XCTestCase {
  func testServices() {
    let bundle = Bundle(for: Services.self)
    let paths = bundle.paths(forResourcesOfType: ".txt", inDirectory: "Services.bundle")
    XCTAssert(!paths.isEmpty, "No resources of Services.bundle for: \(bundle.bundlePath)")
  }
}
