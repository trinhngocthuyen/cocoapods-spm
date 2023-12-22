import Orcam
import SwiftUIX

@Singleton
struct CommonUI {}

private struct _ScrollView {
  var body: some View {
    ScrollView {}.dismissDisabled(false)
  }
}
