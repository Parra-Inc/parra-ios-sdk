//
//  View+Changelog.swift
//  Parra
//
//  Created by Mick MacCallum on 3/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension View {
    /// Automatically fetches the feedback form with the provided id and
    /// presents it in a sheet based on the value of the `isPresented` binding.
    @MainActor
    func presentParraChangelog(
        isPresented: Binding<Bool>,
        config: ChangelogWidgetConfig = .default,
        localBuilder: ChangelogWidgetBuilderConfig = .init(),
        onDismiss: ((SheetDismissType) -> Void)? = nil
    ) -> some View {
        let params = ChangelogParams(
            limit: 15,
            offset: 0
        )

        return loadAndPresentSheet(
            loadType: .init(
                get: {
                    if isPresented.wrappedValue {
                        return .transform(params)
                    } else {
                        return nil
                    }
                },
                set: { type in
                    if type == nil {
                        isPresented.wrappedValue = false
                    }
                }
            ),
            with: .changelogLoader(
                config: config,
                localBuilder: localBuilder
            ),
            onDismiss: onDismiss
        )
    }

    @MainActor
    func presentParraReleaseNotes(
    ) {}
}
