//
//  XCTestCase+createMocks.swift
//  ParraTests
//
//  Created by Mick MacCallum on 7/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import XCTest
@testable import Parra

@MainActor
extension XCTestCase {
    func createMockParra(
        state: ParraState = ParraState(),
        tenantId: String = UUID().uuidString,
        applicationId: String = UUID().uuidString
    ) async -> MockParra {

        let mockNetworkManager = await createMockNetworkManager(
            state: state,
            tenantId: tenantId,
            applicationId: applicationId
        )
        let syncState = ParraSyncState()
        let configState = ParraConfigState()
        let notificationCenter = ParraNotificationCenter.default

        let sessionManager = ParraSessionManager(
            dataManager: mockNetworkManager.dataManager,
            networkManager: mockNetworkManager.networkManager
        )

        let syncManager = ParraSyncManager(
            state: state,
            syncState: syncState,
            networkManager: mockNetworkManager.networkManager,
            sessionManager: sessionManager,
            notificationCenter: notificationCenter
        )

        return MockParra(
            parra: Parra(
                state: state,
                configState: configState,
                dataManager: mockNetworkManager.dataManager,
                syncManager: syncManager,
                sessionManager: sessionManager,
                networkManager: mockNetworkManager.networkManager,
                notificationCenter: notificationCenter
            ),
            mockNetworkManager: mockNetworkManager,
            tenantId: tenantId,
            applicationId: applicationId
        )
    }

    func createMockNetworkManager(
        state: ParraState = .initialized,
        tenantId: String = UUID().uuidString,
        applicationId: String = UUID().uuidString,
        authenticationProvider: ParraAuthenticationProviderFunction? = nil
    ) async -> MockParraNetworkManager {
        let dataManager = MockDataManager()
        let urlSession = MockURLSession(testCase: self)
        let configState = ParraConfigState.initialized(
            tenantId: tenantId,
            applicationId: applicationId
        )

        let networkManager = ParraNetworkManager(
            state: state,
            configState: configState,
            dataManager: dataManager,
            urlSession: urlSession
        )

        await networkManager.updateAuthenticationProvider(authenticationProvider)

        return MockParraNetworkManager(
            networkManager: networkManager,
            dataManager: dataManager,
            urlSession: urlSession,
            tenantId: tenantId,
            applicationId: applicationId
        )
    }
}
