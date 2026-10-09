import SwiftUI

struct ContentView: View {
    @State var selectedTab: AppTabs = .apod

    var body: some View {
        TabView(selection: $selectedTab) {
            // Home view for APOD
            Tab("Home", systemImage: "house", value: .apod) {
                APODView()
            }
            // Explore view
            Tab("Explore", systemImage: "safari", value: .explore) {
                ExploreView()
            }
            // Favorites view
            Tab("Favorites", systemImage: "heart", value: .favourites) {
                FavouritesView()
            }
            // search
            Tab(value: .search, role: .search) {
                ImageSearchView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabViewSearchActivation(.searchTabSelection)
    }
}

enum AppTabs: Hashable {
    case apod
    case explore
    case favourites
    case search
}
