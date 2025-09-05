import DebugKit
import GoogleMaps
import NetworkLogger
import NetworkInterceptor
import SnapKit
import SwiftUIX
import SwiftyBeaver
import MQTTNIO

struct Foo {
  func check() {
    print(AnyButtonStyle.self) // SwiftUIX
    print(SwiftyBeaver.self) // SwiftyBeaver
    print(Constraint.self) // SnapKit
    print(DebugKit.self) // DebugKit
    print(GMSAddress.self) // GoogleMaps
    print(NetworkLogger.self) // NetworkLogger
    print(NetworkInterceptor.self) // NetworkInterceptor
    print(MQTTClient.self) // MQTTClient
  }
}

import Orcam
import Wizard
import MacroCodableKit

@AllOfCodable // MacroCodableKit
@Init // Orcam
struct FooMacro {
  let x: Int

  func check() {
    let color = #uiColor(0xff0000)
    print("color: \(color)")
  }
}
