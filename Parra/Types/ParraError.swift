//
//  ParraError.swift
//  Parra
//
//  Created by Michael MacCallum on 2/26/22.
//

import Foundation

public enum ParraError: LocalizedError, CustomStringConvertible {
    case message(String)
    case generic(String, Error?)
    case notInitialized
    case missingAuthentication
    case authenticationFailed(String)
    case networkError(
        request: URLRequest,
        response: HTTPURLResponse,
        responseData: Data
    )
    case fileSystem(path: URL, message: String)
    case jsonError(String)
    case unknown

    // MARK: - Public

    /// A simple error description string for cases where we don't have more complete control
    /// over the output formatting. Interally, we want to always use `Parra/ParraErrorWithExtra`
    /// in combination with the `ParraError/errorDescription` and ``ParraError/description``
    /// fields instead of this.
    public var description: String {
        let baseMessage = errorDescription

        switch self {
        case .message, .unknown, .jsonError, .notInitialized,
             .missingAuthentication:
            return baseMessage
        case .generic(_, let error):
            if let error {
                return "\(baseMessage) Error: \(error)"
            }

            return baseMessage
        case .authenticationFailed(let error):
            return "\(baseMessage) Error: \(error)"
        case .networkError(let request, let response, let data):
            #if DEBUG
            let dataString = String(data: data, encoding: .utf8) ?? "unknown"
            return "\(baseMessage)\nRequest: \(request)\nResponse: \(response)\nData: \(dataString)"
            #else
            return "\(baseMessage)\nRequest: \(request)\nResponse: \(response)\nData: \(data.count) byte(s)"
            #endif
        case .fileSystem(let path, let message):
            return "\(baseMessage)\nPath: \(path.relativeString)\nError: \(message)"
        }
    }

    // MARK: - Internal

    var errorDescription: String {
        switch self {
        case .message(let string):
            return string
        case .generic(let string, let error):
            if let error {
                let formattedError = LoggerFormatters
                    .extractMessage(from: error)

                return "\(string) Error: \(formattedError)"
            }

            return string
        case .notInitialized:
            return "Parra has not been initialized. Call Parra.initialize() in applicationDidFinishLaunchingWithOptions."
        case .missingAuthentication:
            return "An authentication provider has not been set. Add Parra.initialize() to your applicationDidFinishLaunchingWithOptions method."
        case .authenticationFailed:
            return "Invoking the authentication provider passed to Parra.initialize() failed."
        case .networkError:
            return "A network error occurred."
        case .jsonError(let string):
            return "JSON error occurred. Error: \(string)"
        case .fileSystem:
            return "A file system error occurred."
        case .unknown:
            return "An unknown error occurred."
        }
    }
}

// MARK: ParraSanitizedDictionaryConvertible

extension ParraError: ParraSanitizedDictionaryConvertible {
    var sanitized: ParraSanitizedDictionary {
        switch self {
        case .generic(_, let error):
            if let error {
                return [
                    "error_description": error.localizedDescription
                ]
            }

            return [:]
        case .authenticationFailed(let error):
            return [
                "authentication_error": error
            ]
        case .networkError(let request, let response, let body):
            var bodyInfo: [String: Any] = [
                "length": body.count
            ]

            #if DEBUG
            let dataString = String(
                data: body,
                encoding: .utf8
            ) ?? "unknown"

            bodyInfo["data"] = dataString
            #endif

            return [
                "request": request.sanitized.dictionary,
                "response": response.sanitized.dictionary,
                "body": bodyInfo
            ]
        case .fileSystem(let path, let message):
            return [
                "path": path.relativeString,
                "error_description": message
            ]
        case .notInitialized, .missingAuthentication, .message, .jsonError,
             .unknown:
            return [:]
        }
    }
}
