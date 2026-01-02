//
//  FeedWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import SwiftUI

struct FeedWidget: ParraContainer {
    // MARK: - Lifecycle

    init(
        config: ParraFeedConfiguration,
        contentObserver: ContentObserver,
        navigationPath: Binding<NavigationPath>
    ) {
        self.config = config
        self._contentObserver = StateObject(wrappedValue: contentObserver)

        _navigationPath = navigationPath
    }

    // MARK: - Internal

    @StateObject var contentObserver: ContentObserver
    @Binding var navigationPath: NavigationPath

    let config: ParraFeedConfiguration

    var items: Binding<[ParraFeedItem]> {
        return $contentObserver.feedPaginator.items
    }

    var body: some View {
        let defaultWidgetAttributes = ParraAttributes.Widget.default(
            with: parraTheme
        )

        let contentPadding = parraTheme.padding.value(
            for: defaultWidgetAttributes.contentPadding
        )

        scrollView(
            with: contentPadding
        )
        .applyWidgetAttributes(
            attributes: defaultWidgetAttributes.withoutContentPadding(),
            using: parraTheme
        )
        .environment(config)
        .environment(componentFactory)
        .environmentObject(contentObserver)
        .onAppear {
            contentObserver.loadInitialFeedItems()
        }
        .navigationTitle(config.navigationTitle)
    }

    func scrollView(
        with contentPadding: EdgeInsets
    ) -> some View {
        GeometryReader { geometry in
            ParraMediaAwareScrollView(
                additionalScrollContentMargins: EdgeInsets(
                    vertical: headerSpace(from: contentPadding) / 2
                )
            ) {
                VStack(spacing: 0) {
                    AnyView(config.headerViewBuilder())
                        .layoutPriority(10)
                        .modifier(SizeCalculator())
                        .onPreferenceChange(SizePreferenceKey.self) { size in
                            headerHeight = size.height
                        }

                    ParraFeedListView(
                        items: items.wrappedValue,
                        itemSpacing: config.itemSpacing,
                        containerGeometry: geometry,
                        navigationPath: $navigationPath,
                        itemAtIndexDidAppear: { index in
                            contentObserver.feedPaginator.loadMore(after: index)
                        },
                        performActionForFeedItemData: contentObserver
                            .performActionForFeedItemData
                    )
                    .redacted(
                        when: contentObserver.feedPaginator.isShowingPlaceholders
                    )
                    .emptyPlaceholder(items) {
                        if !contentObserver.feedPaginator.isLoading {
                            componentFactory.buildEmptyState(
                                config: .default,
                                content: contentObserver.content.emptyStateView,
                                onPrimaryAction: {}
                            )
                            .frame(
                                minHeight: geometry.size
                                    .height - headerHeight - footerHeight
                            )
                            .layoutPriority(1)
                        } else {
                            EmptyView()
                        }
                    }
                    .errorPlaceholder(contentObserver.feedPaginator.error) {
                        componentFactory.buildEmptyState(
                            config: .errorDefault,
                            content: contentObserver.content.errorStateView
                        )
                        .frame(
                            minHeight: geometry.size.height - headerHeight - footerHeight
                        )
                        .layoutPriority(1)
                    }

                    Spacer()

                    if contentObserver.feedPaginator.isLoading {
                        VStack(alignment: .center) {
                            ProgressView()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(contentPadding)
                    }

                    AnyView(config.footerViewBuilder())
                        .layoutPriority(10)
                        .modifier(SizeCalculator())
                        .onPreferenceChange(SizePreferenceKey.self) { size in
                            footerHeight = size.height
                        }
                }
                .padding(0)
                .frame(
                    minHeight: geometry.size.height
                )
            }
            // A limited number of placeholder cells will be generated.
            // Don't allow scrolling past them while loading.
            .scrollDisabled(
                contentObserver.feedPaginator.isShowingPlaceholders
            )
            .refreshable {
                contentObserver.refresh()
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
        }
    }

    func headerSpace(
        from contentPadding: EdgeInsets
    ) -> CGFloat {
        return contentPadding.bottom
    }

    // MARK: - Private

    @State private var headerHeight: CGFloat = 0
    @State private var footerHeight: CGFloat = 0

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
}

#Preview {
    ParraContainerPreview<FeedWidget>(
        config: .default
    ) { parra, _, config in
        FeedWidget(
            config: .default,
            contentObserver: .init(
                initialParams: FeedWidget.ContentObserver
                    .InitialParams(
                        feedId: "test-feed-id",
                        config: .default,
                        feedCollectionResponse: .validStates()[0],
                        api: parra.parraInternal.api
                    )
            ),
            navigationPath: .constant(.init())
        )
    }
}
