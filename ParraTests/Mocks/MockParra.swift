//
//  MockParra.swift
//  ParraTests
//
//  Created by Mick MacCallum on 7/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
@testable import Parra

struct MockParra {
    let parra: Parra
    let mockNetworkManager: MockParraNetworkManager

    let dataManager: ParraDataManager
    let syncManager: ParraSyncManager
    let sessionManager: ParraSessionManager
    let networkManager: ParraNetworkManager
    let notificationCenter: NotificationCenterType

    let tenantId: String
    let applicationId: String
}
