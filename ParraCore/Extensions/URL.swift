//
//  URL.swift
//  ParraCore
//
//  Created by Mick MacCallum on 12/30/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

internal extension URL {
    func safeAppendDirectory(_ dir: String) -> URL {
        if #available(iOS 16.0, *) {
            return appending(path: dir, directoryHint: .isDirectory)
        } else {
            return appendingPathComponent(dir, isDirectory: true)
        }
    }

    func safeAppendPathComponent(_ pathComponent: String) -> URL {
        if #available(iOS 16.0, *) {
            return appending(component: pathComponent, directoryHint: .notDirectory)
        } else {
            return appendingPathComponent(pathComponent, isDirectory: false)
        }
    }

    func safeNonEncodedPath() -> String {
        if #available(iOS 16.0, *) {
            return path(percentEncoded: false)
        } else {
            return path
        }
    }
}
