import XCTest

final class StaticResourcesTests: XCTestCase {
  func testResourcesCopiedToMainBundle() {
    expectFiles(ofType: "trace", inDir: "DebugKit_DebugKit.bundle")
    expectFiles(ofType: "png", inDir: "GoogleMaps_GoogleMapsTarget.bundle/GoogleMaps.bundle")
    expectFiles(ofType: "xcprivacy", inDir: "SnapKit_SnapKit.bundle")
  }

  private func expectFiles(
    ofType resourceType: String,
    inDir: String? = nil,
    _ file: StaticString = #file,
    _ line: UInt = #line
  ) {
    let paths = Bundle.main.paths(forResourcesOfType: resourceType, inDirectory: inDir)
    if paths.isEmpty {
      XCTFail("No resources of type \(resourceType) in dir: \(inDir ?? "nil")", file: file, line: line)
    }
  }
}
