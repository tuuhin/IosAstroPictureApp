import SwiftUI

struct ImageSearchView: View {
    @State private var searchText: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                Text("This is some result")
            }
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer,
                prompt: "Search for images"
            )
        }
    }
}
