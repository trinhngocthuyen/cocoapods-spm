import DebugKit
import GoogleMaps
import NetworkLogger
import OpenTelemetrySdk
import SnapKit
import SwiftUIX
import SwiftyBeaver

struct Foo {
  func check() {
    print(AnyButtonStyle.self) // SwiftUIX
    print(SwiftyBeaver.self) // SwiftyBeaver
    print(Constraint.self) // SnapKit
    print(DoubleCounterSdk.self) // OpenTelemetrySdk
    print(DebugKit.self) // DebugKit
    print(GMSAddress.self) // GoogleMaps
    print(NetworkLogger.self) // NetworkLogger
  }
}

import Orcam
import MacroCodableKit

@AllOfCodable // MacroCodableKit
@Init // Orcam
struct FooMacro {
  let x: Int
}
