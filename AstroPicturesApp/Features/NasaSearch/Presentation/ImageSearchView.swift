import SwiftUI

struct ImageSearchView: View {
    @State private var viewModel = ImageSearchViewModel()
    @State private var searchText = ""

    /// Shared namespace that drives the hero (zoom) transition between a grid
    /// tile and its detail screen.
    @Namespace private var heroNamespace

    /// Width of the grid's scroll area, kept current by `onGeometryChange` so
    /// the columns reflow on any size change.
    @State private var gridWidth: CGFloat = 0

    private var columns: [GridItem] {
        AdaptiveGrid.columns(for: gridWidth)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Search")
                .navigationDestination(for: NasaImageSearchResultModel.self) { result in
                    NasaImageSearchDetailView(
                        result: result,
                        heroNamespace: heroNamespace
                    )
                }
                .searchable(
                    text: $searchText,
                    placement: .navigationBarDrawer,
                    prompt: "Search NASA's image library"
                )
                .onSubmit(of: .search) {
                    Task { await viewModel.search(searchText) }
                }
                .toolbar { clearToolbarItem }
                .task(id: searchText) {
                    await searchAfterTypingPause()
                }
                .refreshable {
                    await viewModel.refresh()
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView("Searching…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case let .error(error):
            ContentUnavailableView {
                Label("Search Failed", systemImage: "exclamationmark.triangle")
            } description: {
                Text(viewModel.errorMessage ?? error.localizedDescription)
            } actions: {
                Button("Try Again") {
                    Task { await viewModel.search(searchText, force: true) }
                }
                .buttonStyle(.borderedProminent)
            }

        case let .data(results, hasMore):
            grid(
                results: results,
                isLoadingMore: false,
                canLoadMore: hasMore,
                paginationError: nil
            )

        case let .dataLoadingMore(results):
            grid(
                results: results,
                isLoadingMore: true,
                canLoadMore: false,
                paginationError: nil
            )

        case let .dataError(results, error, hasMore):
            grid(
                results: results,
                isLoadingMore: false,
                canLoadMore: hasMore,
                paginationError: viewModel.errorMessage ?? error.localizedDescription
            )
        }
    }

    @ViewBuilder
    private func grid(
        results: [NasaImageSearchResultModel],
        isLoadingMore: Bool,
        canLoadMore: Bool,
        paginationError: String?
    ) -> some View {
        ScrollView {
            LazyVStack(spacing: AdaptiveGrid.spacing) {
                if viewModel.isIdle {
                    idlePrompt
                }
                else if results.isEmpty {
                    noResults
                }
                else {
                    if viewModel.totalHits > 0 {
                        resultCount
                    }

                    LazyVGrid(columns: columns, spacing: AdaptiveGrid.spacing) {
                        ForEach(results) { result in
                            NavigationLink(value: result) {
                                AstroPictureTile(result: result)
                                    .matchedTransitionSource(
                                        id: result.id,
                                        in: heroNamespace
                                    ) { source in
                                        source
                                            .background(.black)
                                            .clipShape(
                                                RoundedRectangle(
                                                    cornerRadius: 16, style: .continuous)
                                            )
                                    }
                            }
                            .buttonStyle(.plain)
                            .onAppear {
                                if result.id == results.last?.id {
                                    Task {
                                        await viewModel.loadNextPageIfNeeded(
                                            currentItem: result)
                                    }
                                }
                            }
                        }
                    }
                }

                footer(
                    results: results,
                    isLoadingMore: isLoadingMore,
                    canLoadMore: canLoadMore,
                    paginationError: paginationError
                )
            }
            .padding(.horizontal, AdaptiveGrid.horizontalInset)
            .padding(.top, 8)
        }
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
        } action: { width in
            gridWidth = width
        }
    }

    private var idlePrompt: some View {
        ContentUnavailableView {
            Label("Search the NASA Image Library", systemImage: "magnifyingglass")
        } description: {
            Text("Find images from NASA's archive.")
        }
        .padding(.top, 48)
    }

    private var noResults: some View {
        ContentUnavailableView.search(text: searchText)
            .padding(.top, 48)
    }

    private var resultCount: some View {
        Text("\(viewModel.totalHits) results")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
    }

    @ViewBuilder
    private func footer(
        results: [NasaImageSearchResultModel],
        isLoadingMore: Bool,
        canLoadMore: Bool,
        paginationError: String?
    ) -> some View {
        if isLoadingMore {
            ProgressView()
                .padding(.vertical, 20)
        }
        else if let paginationError, let lastResult = results.last {
            VStack(spacing: 8) {
                Text(paginationError)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button("Retry Loading More") {
                    Task {
                        await viewModel.loadNextPageIfNeeded(currentItem: lastResult)
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding(.vertical, 20)
        }
        else if !canLoadMore, !results.isEmpty {
            Text("End of results")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.vertical, 20)
        }
    }

    @ToolbarContentBuilder
    private var clearToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if viewModel.hasResults || !searchText.isEmpty {
                Button {
                    clear()
                } label: {
                    Label("Clear Results", systemImage: "xmark.circle.fill")
                }
            }
        }
    }

    private func clear() {
        searchText = ""
        viewModel.clear()
    }

    /// Waits for a pause in typing before spending a request. `.task(id:)`
    /// cancels this whenever `searchText` changes, so only the last edit runs.
    private func searchAfterTypingPause() async {
        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !text.isEmpty else {
            viewModel.clear()
            return
        }

        try? await Task.sleep(for: .milliseconds(350))
        guard !Task.isCancelled else { return }

        await viewModel.search(text)
    }
}

#Preview {
    ImageSearchView()
}
