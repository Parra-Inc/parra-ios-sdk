//
//  AppReleaseContentObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 3/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

class AppReleaseContentObserver: ObservableObject {
    // MARK: - Lifecycle

    init(
        stub: AppReleaseStub,
        networkManager: ParraNetworkManager
    ) {
        self.content = AppReleaseContent(stub)
        self.networkManager = networkManager
    }

    // MARK: - Internal

    @Published private(set) var content: AppReleaseContent
    @Published private(set) var isLoading = false

    let networkManager: ParraNetworkManager

    func loadSections() async {
        do {
            await MainActor.run {
                isLoading = true
            }

            let response = try await networkManager.getRelease(
                with: content.id
            )

            await MainActor.run {
                content = AppReleaseContent(response)
            }
        } catch {
            Logger.error("Error loading sections for release", error, [
                "releaseId": content.id
            ])
        }

        await MainActor.run {
            isLoading = false
        }
    }
}
