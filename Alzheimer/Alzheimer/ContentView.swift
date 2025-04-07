import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink("进入音频视图") {
                    AudioView()
                }
                .padding()
            }
        }.navigationTitle("Navigation")
    }
}

#Preview {
    ContentView()
}
