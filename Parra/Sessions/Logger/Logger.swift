//
//  Logger.swift
//  Parra
//
//  Created by Mick MacCallum on 7/5/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public class Logger {
    public static var loggerBackend: ParraLoggerBackend?

    public let context: ParraLoggerContext
    public private(set) weak var parent: Logger?

    /// Whether or not logging is enabled on this logger instance. Logging is enabled
    /// by default. If you disable logging, logs are ignored until re-enabling.
    public var isEnabled = true

    public init(
        category: String? = nil,
        extra: [String: Any]? = nil,
        fileId: String = #fileID
    ) {
        if let category {
            context = ParraLoggerContext(
                fileId: fileId,
                categories: [category],
                extra: extra ?? [:]
            )
        } else {
            context = ParraLoggerContext(
                fileId: fileId,
                categories: [],
                extra: extra ?? [:]
            )
        }
    }

    internal init(
        parent: Logger,
        context: ParraLoggerContext
    ) {
        self.context = context
        self.parent = parent
    }

    internal func logToBackend(
        level: ParraLogLevel,
        message: ParraLazyLogParam,
        extraError: @escaping () -> Error? = { nil },
        extra: @escaping () -> [String: Any]? = { nil },
        callSiteContext: ParraLoggerCallSiteContext,
        threadInfo: ParraLoggerThreadInfo
    ) -> ParraLogMarker {
        guard isEnabled else {
            return ParraLogMarker(startingContext: callSiteContext)
        }

        Logger.loggerBackend?.log(
            level: level,
            context: self.context,
            message: message,
            extraError: extraError,
            extra: extra,
            callSiteContext: callSiteContext,
            threadInfo: threadInfo
        )

        return ParraLogMarker(
            context: self.context,
            startingContext: callSiteContext
        )
    }

    internal static func logToBackend(
        level: ParraLogLevel,
        message: ParraLazyLogParam,
        context: ParraLoggerContext? = nil,
        extraError: @escaping () -> Error? = { nil },
        extra: @escaping () -> [String: Any]? = { nil },
        callSiteContext: ParraLoggerCallSiteContext,
        threadInfo: ParraLoggerThreadInfo
    ) -> ParraLogMarker {
        // TODO: If logger backend isn't configured yet, check env config, apply format, print to console outside of session events.
        // We don't check that the logger is enabled here because this only applies to
        // logger instances.
        loggerBackend?.log(
            level: level,
            context: nil,
            message: message,
            extraError: extraError,
            extra: extra,
            callSiteContext: callSiteContext,
            threadInfo: threadInfo
        )

        return ParraLogMarker(
            context: context,
            startingContext: callSiteContext
        )
    }

    public func enableLogging() {
        isEnabled = true
    }

    public func disableLogging() {
        isEnabled = false
    }
}
