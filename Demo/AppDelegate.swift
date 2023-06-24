//
//  AppDelegate.swift
//  Parra Feedback SDK Demo
//
//  Created by Michael MacCallum on 11/22/21.
//

import UIKit
import ParraCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        guard NSClassFromString("XCTestCase") == nil else {
            return true
        }

        let myAppAccessToken = "9B5CDA6B-7538-4A2A-9611-7308D56DFFA1"
        let myAppTenantId    = "f2d60da7-8aea-4882-9ee7-307e0ff18728"
        let myApplicationId  = "cb22fd90-2abc-4044-b985-fcb86f61daa9"

        Parra.initialize(
            config: .default,
            authProvider: .default(tenantId: myAppTenantId, applicationId: myApplicationId) {
                var request = URLRequest(
                    // Replace this with your Parra access token generation endpoint
                    url: URL(string: "http://localhost:8080/v1/parra/auth/token")!
                )

                request.httpMethod = "POST"
                // Replace this with your app's way of authenticating users
                request.setValue("Bearer \(myAppAccessToken)", forHTTPHeaderField: "Authorization")

                let (data, _) = try await URLSession.shared.data(for: request)
                let response = try JSONDecoder().decode([String: String].self, from: data)

                return response["access_token"]!
            }
        )

        // Call this after Parra.initialize()
        application.registerForRemoteNotifications()

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(
        _ application: UIApplication,
        didDiscardSceneSessions sceneSessions: Set<UISceneSession>
    ) {}

    // MARK: Push Notifications

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Parra.registerDevicePushToken(deviceToken)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        Parra.didFailToRegisterForRemoteNotifications(with: error)
    }
}
