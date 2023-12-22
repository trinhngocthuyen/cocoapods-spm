import SwiftUI

struct HomeScreen: View {
  @StateObject private var vm: HomeVM = .init()

  var body: some View {
    NavigationStack {
      VStack {
        Text("No content yet")
      }
      .navigationTitle("Home")
    }
  }
}

#Preview {
  HomeScreen()
}
