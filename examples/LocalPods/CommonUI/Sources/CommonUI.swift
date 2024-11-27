import SwiftUIX

private struct _ScrollView {
  var body: some View {
    ScrollView {}.dismissDisabled(false)
  }
}

import Orcam
import MacroCodableKit

@AllOfCodable // MacroCodableKit
@Init // Orcam
struct FooMacro {
  let x: Int
}
