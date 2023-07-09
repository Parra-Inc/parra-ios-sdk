//
//  ParraLoggerEnvironment.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

// TODO: Do we need another option for `staging`?

/// Which environment the Parra Logger is executing in. When in `debug`
/// mode, logs are printed to the console. When in `production` mode, logs
/// are uploaded to Parra with other session data. By default, the `automatic`
/// options is set, indicating that the `DEBUG` compilation condition will be
/// used to determine if the environment is `debug` or `production`.
/// This option is exposed in case you have additional schemes besides DEBUG
/// and RELEASE and want to customize your log output in these cases.
public enum ParraLoggerEnvironment {
    public static let `default` = ParraLoggerEnvironment.automatic

    case debug
    case production

    case automatic

    internal var hasDebugBehavior: Bool {
        switch self {
        case .debug:
            return true
        case .production:
            return false
        case .automatic:
#if DEBUG
            return true
#else
            return false
#endif
        }
    }
}
