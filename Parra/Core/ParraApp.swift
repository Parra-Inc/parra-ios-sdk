//
//  ParraApp.swift
//  Parra
//
//  Created by Mick MacCallum on 2/9/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

/// A top level wrapper around your SwiftUI app's content. When creating a
/// ``ParraApp``, you should supply it with an authentication provider and any
/// options that you would like to customize. The authentication provider is a
/// function that will be invoked periodically when Parra needs to
/// reauthenticate the user. This mechanism allows for Parra's authentication of
/// a user to be linked to their authentication with your backend. This function
/// is expected to resolve to an access token generated by your backend.
///
/// ## Example
/// Update your `@main` `App` declaration to wrap your `Scene` in a
/// ``ParraApp`` instance.
///
/// ```
/// import Parra
///
/// var body: some Scene {
///     ParraApp(
///         authProvider: // ...
///     ) {
///         WindowGroup {
///             ContentView()
///         }
///     }
/// }
/// ```
///
/// Parra automatically creates an app delegate internally that is used to
/// intercept lifecycle events. If your app needs to implement its own app
/// delegate, you can utilize the optional `appDelegateType` parameter to pass
/// your app delegate class. Your app delegate class should be a subclass of
/// ``Parra/ParraAppDelegate`` and be sure to invoke the super implementation of
/// any delegate methods that it overrides, in order to avoid unintended
/// behavior.
///
/// ## Example with App Delegate
/// ```
/// import Parra
///
/// class MyAppDelegate: ParraAppDelegate {
///     override func application(
///         _ application: UIApplication,
///         didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
///     ) {
///         super.application(
///             application,
///             didRegisterForRemoteNotificationsWithDeviceToken: deviceToken
///         )
///
///         // ...
///     }
/// }
///
/// var body: some Scene {
///     ParraApp(
///         authProvider: // ...,
///         appDelegateType: MyAppDelegate.self
///     ) {
///         WindowGroup {
///             ContentView()
///         }
///     }
/// }
/// ```
///
@MainActor
public struct ParraApp<Content, DelegateType>: Scene
    where Content: Scene, DelegateType: ParraAppDelegate
{
    // MARK: - Lifecycle

    public init(
        authProvider: ParraAuthenticationProviderType,
        options: [ParraConfigurationOption] = [],
        appDelegateType: DelegateType.Type = ParraAppDelegate.self,
        sceneContent: @MainActor @escaping () -> Content
    ) {
        self.content = sceneContent

        let (parra, appState) = Parra.createParraInstance(
            authProvider: authProvider,
            configuration: ParraConfiguration(
                options: options
            )
        )

        _appDelegate = UIApplicationDelegateAdaptor(appDelegateType)
        _appDelegate.wrappedValue.parra = parra

        _parraAppState = StateObject(wrappedValue: appState)

        self.parra = parra

        parra.initialize(
            with: authProvider
        )
    }

    // MARK: - Public

    public var body: some Scene {
        content()
            .environment(parra)
    }

    // MARK: - Internal

    @UIApplicationDelegateAdaptor(DelegateType.self) var appDelegate
    @SceneBuilder var content: () -> Content
    @StateObject var parraAppState: ParraAppState

    // MARK: - Private

    private let parra: Parra
}
