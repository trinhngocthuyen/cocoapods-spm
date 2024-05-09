
import DebugKit
import GoogleMaps
import NetworkLogger
import OpenTelemetrySdk
import SamplePackageB_iOS
import SnapKit
import SwiftUIX
import SwiftyBeaver

struct Foo {
  let x: Int

  func check() {
    print(AnyButtonStyle.self) // SwiftUIX
    print(SwiftyBeaver.self) // SwiftyBeaver
    print(Constraint.self) // SnapKit
    print(DoubleCounterSdk.self) // OpenTelemetrySdk
    print(DebugKit.self) // DebugKit
    print(GMSAddress.self) // GoogleMaps
    print(NetworkLogger.self) // NetworkLogger
    print(SampleStruct.self) // SamplePackageB_iOS
  }
}
