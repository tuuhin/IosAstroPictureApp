import SwiftUI

struct ExploreView: View {
    @State private var viewModel: ExploreViewModel = .init()

    /// Shared namespace that drives the hero (zoom) transition between a grid
    /// tile and its detail screen.
    @Namespace private var heroNamespace

    /// Width of the grid's scroll area, kept current by `onGeometryChange`.
    ///
    /// Reading the size class alone isn't enough: on a regular iPhone it stays
    /// `.compact` in both orientations, so the grid would never reflow on
    /// rotation, Split View or resize. Measuring the space actually available
    /// makes the columns adapt to *any* size change — which is also exactly what
    /// iPhone Duo needs.
    @State private var gridWidth: CGFloat = 0

    /// Even column count so the grid divides cleanly either side of a fold.
    private var columns: [GridItem] {
        AdaptiveGrid.columns(for: gridWidth)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Explore")
                .navigationDestination(for: AstroPictureModel.self) { picture in
                    ExploreDetailView(
                        picture: picture,
                        heroNamespace: heroNamespace
                    ) { updated in
                        Task { await viewModel.toggleFavourite(updated) }
                    }
                }
                .refreshable {
                    await viewModel.refresh()
                }
        }
        .task {
            if viewModel.state.items.isEmpty {
                await viewModel.loadInitial()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading:
            ProgressView("Loading pictures…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case let .error(error):
            ContentUnavailableView {
                Label("Unable to Load", systemImage: "exclamationmark.triangle")
            } description: {
                Text(viewModel.errorMessage ?? error.localizedDescription)
            } actions: {
                Button("Try Again") {
                    Task { await viewModel.loadInitial() }
                }
                .buttonStyle(.borderedProminent)
            }

        case let .data(pictures, hasMore):
            grid(
                pictures: pictures,
                isLoadingMore: false,
                canLoadMore: hasMore,
                paginationError: nil
            )

        case let .dataLoadingMore(pictures):
            grid(
                pictures: pictures,
                isLoadingMore: true,
                canLoadMore: false,
                paginationError: nil
            )

        case let .dataError(pictures, error, hasMore):
            grid(
                pictures: pictures,
                isLoadingMore: false,
                canLoadMore: hasMore,
                paginationError: viewModel.errorMessage ?? error.localizedDescription
            )
        }
    }

    @ViewBuilder
    private func grid(
        pictures: [AstroPictureModel],
        isLoadingMore: Bool,
        canLoadMore: Bool,
        paginationError: String?
    ) -> some View {
        ScrollView {
            LazyVStack(spacing: AdaptiveGrid.spacing) {
                if viewModel.isShowingCache {
                    cacheBanner
                }

                if pictures.isEmpty {
                    ContentUnavailableView(
                        "No Pictures Found",
                        systemImage: "sparkles",
                        description: Text("Pull to refresh and check back soon.")
                    )
                    .padding(.top, 48)
                }
                else {
                    LazyVGrid(columns: columns, spacing: AdaptiveGrid.spacing) {
                        ForEach(pictures, id: \.postId) { picture in
                            NavigationLink(value: picture) {
                                AstroPictureTile(picture: picture)
                                    .matchedTransitionSource(
                                        id: picture.postId,
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
                                if picture.postId == pictures.last?.postId {
                                    Task {
                                        await viewModel.loadNextPageIfNeeded(currentItem: picture)
                                    }
                                }
                            }
                        }
                    }
                }
                footer(
                    pictures: pictures,
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

    private var cacheBanner: some View {
        Label("Showing cached pictures — you're offline", systemImage: "wifi.slash")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.quaternary.opacity(0.6), in: RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder
    private func footer(
        pictures: [AstroPictureModel],
        isLoadingMore: Bool,
        canLoadMore: Bool,
        paginationError: String?
    ) -> some View {
        if isLoadingMore {
            ProgressView()
                .padding(.vertical, 20)
        }
        else if let paginationError, let lastPicture = pictures.last {
            VStack(spacing: 8) {
                Text(paginationError)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button("Retry Loading More") {
                    Task {
                        await viewModel.loadNextPageIfNeeded(currentItem: lastPicture)
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding(.vertical, 20)
        }
        else if !canLoadMore, !pictures.isEmpty {
            Text("You've reached the end")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.vertical, 20)
        }
    }
}

#Preview {
    ExploreView()
}
