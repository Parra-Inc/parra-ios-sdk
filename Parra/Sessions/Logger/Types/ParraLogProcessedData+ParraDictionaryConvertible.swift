//
//  ParraLogProcessedData+ParraDictionaryConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension ParraLogProcessedData: ParraDictionaryConvertible {
    var dictionary: [String : Any] {
        var params: [String : Any] = [
            "level": level.loggerDescription,
            "message": message,
            "call_site": [
                "file_id": callSiteContext.fileId,
                "function": callSiteContext.function,
                "line": callSiteContext.line,
                "column": callSiteContext.column
            ] as [String : Any]
        ]

        if let loggerContext {
            params["logger_context"] = loggerContext.dictionary
        }

        if let extra, !extra.isEmpty {
            params["extra"] = extra
        }

        let threadInfoDict = callSiteContext.threadInfo.dictionary
        if !threadInfoDict.isEmpty {
            params["thread"] = threadInfoDict
        }

        return params
    }
}

