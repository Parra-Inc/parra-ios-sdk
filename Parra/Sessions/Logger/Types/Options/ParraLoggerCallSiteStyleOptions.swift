//
//  ParraLoggerCallSiteStyleOptions.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraLoggerCallSiteStyleOptions: OptionSet {
    // MARK: Lifecycle

    public init(rawValue: Int8) {
        self.rawValue = rawValue
    }

    // MARK: Public

    public static let `default`: ParraLoggerCallSiteStyleOptions = [
        .function, .line
    ]

    public static let thread = ParraLoggerCallSiteStyleOptions(rawValue: 1 << 0)
    public static let function =
        ParraLoggerCallSiteStyleOptions(rawValue: 1 << 1)
    public static let line = ParraLoggerCallSiteStyleOptions(rawValue: 1 << 2)
    public static let column = ParraLoggerCallSiteStyleOptions(rawValue: 1 << 3)

    public let rawValue: Int8
}
