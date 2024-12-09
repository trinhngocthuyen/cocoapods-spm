import DebugKit
import GoogleMaps
import NetworkLogger
import OpenTelemetrySdk
import SnapKit
import SwiftUIX
import SwiftyBeaver
import MQTTNIO
import AsyncDNSResolver

struct Foo {
  func check() {
    print(AnyButtonStyle.self) // SwiftUIX
    print(SwiftyBeaver.self) // SwiftyBeaver
    print(Constraint.self) // SnapKit
    print(DoubleCounterSdk.self) // OpenTelemetrySdk
    print(DebugKit.self) // DebugKit
    print(GMSAddress.self) // GoogleMaps
    print(NetworkLogger.self) // NetworkLogger
    print(MQTTClient.self) // MQTTClient
    print(AsyncDNSResolver.self) // AsyncDNSResolver
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
