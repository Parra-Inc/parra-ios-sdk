//
//  MockURLSessionDataTask.swift
//  ParraTests
//
//  Created by Mick MacCallum on 7/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal class MockURLSessionDataTask: URLSessionDataTask {
    let request: URLRequest
    let dataTaskResolver: DataTaskResolver
    let handler: (Data?, URLResponse?, Error?) -> Void

    required init(
        request: URLRequest,
        dataTaskResolver: @escaping DataTaskResolver,
        handler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) {
        self.request = request
        self.dataTaskResolver = dataTaskResolver
        self.handler = handler
    }

    override func resume() {
        Task {
            let (data, response, error) = dataTaskResolver(request)

            try await Task.sleep(nanoseconds: 100_000_000)

            handler(data, response, error)
        }
    }
}
