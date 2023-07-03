//
//  MockParraNetworkManager.swift
//  ParraTests
//
//  Created by Mick MacCallum on 7/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
@testable import Parra

struct MockParraNetworkManager {
    let networkManager: ParraNetworkManager
    let dataManager: MockDataManager
    let urlSession: MockURLSession
    let tenantId: String
    let applicationId: String
}
