import SwiftUIX

private struct _ScrollView {
  var body: some View {
    ScrollView {}.dismissDisabled(false)
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
