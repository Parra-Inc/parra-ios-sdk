//
//  ParraCredentialTests.swift
//  ParraCoreTests
//
//  Created by Mick MacCallum on 8/28/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import XCTest
import ParraCore

final class ParraCredentialTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDecodesFromToken() throws {
        let _ = try JSONDecoder().decode(ParraCredential.self, from: "{\"token\":\"something\"}".data(using: .utf8)!)
    }

    func testDecodesFromAccessToken() throws {
        let _ = try JSONDecoder().decode(ParraCredential.self, from: "{\"access_token\":\"something\"}".data(using: .utf8)!)
    }

    func testEncodesToToken() throws {
        let data = try JSONEncoder().encode(ParraCredential(token: "something"))
        let decoded = try JSONDecoder().decode([String: String].self, from: data)

        XCTAssert(decoded["token"] != nil)
    }
}
