//
//  ParraLogLevel.swift
//  Parra
//
//  Created by Mick MacCallum on 2/17/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import os

public enum ParraLogLevel: Int, Comparable, ParraLogStringConvertible {
    case trace  = 1
    case debug  = 2
    case info   = 4
    case warn   = 8
    case error  = 16
    case fatal  = 32

    internal static let `default` = ParraLogLevel.info

    public init?(name: String) {
        switch name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "trace":
            self = .trace
        case "debug":
            self = .debug
        case "info":
            self = .info
        case "warn":
            self = .warn
        case "error":
            self = .error
        case "fatal":
            self = .fatal
        default:
            return nil
        }
    }

    public static func < (lhs: ParraLogLevel, rhs: ParraLogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    var name: String {
        switch self {
        case .trace:
            return "TRACE"
        case .debug:
            return "DEBUG"
        case .info:
            return "INFO"
        case .warn:
            return "WARN"
        case .error:
            return "ERROR"
        case .fatal:
            return "FATAL"
        }
    }

    var symbol: String {
        switch self {
        case .trace:
            return "🟣"
        case .debug:
            return "🔵"
        case .info:
            return "⚪"
        case .warn:
            return "🟡"
        case .error:
            return "🔴"
        case .fatal:
            return "💀"
        }
    }

    var loggerDescription: String {
        switch self {
        case .trace:
            return "trace"
        case .debug:
            return "debug"
        case .info:
            return "info"
        case .warn:
            return "warn"
        case .error:
            return "error"
        case .fatal:
            return "fatal"
        }
    }

    var osLogType: os.OSLogType {
        switch self {
        case .trace, .debug:
            return .debug
        case .info:
            return .info
        case .warn, .error:
            return .error
        case .fatal:
            return .fault
        }
    }
}
