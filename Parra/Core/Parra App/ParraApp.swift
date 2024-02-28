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
    where Content: View, DelegateType: ParraAppDelegate
{
    // MARK: - Lifecycle

    /// <#Description#>
    /// - Parameters:
    ///   - authProvider: <#authProvider description#>
    ///   - options: <#options description#>
    ///   - appDelegateType: <#appDelegateType description#>
    ///   - sceneContent: <#sceneContent description#>
    ///   - launchScreenType: The type of launch screen that should be displayed
    ///   while Parra is being initialized. This should match up exactly with
    ///   the launch screen that you have configured in your project settings to
    ///   avoid any sharp transitions. If nothing is provided, we will attempt
    ///   to display the right launch screen automatically. This is done by
    ///   checking for a `UILaunchScreen` key in your Info.plist file. If an
    ///   entry is found, its child values will be used to layout the launch
    ///   screen. Next we look for the `UILaunchStoryboardName` key. If this is
    ///   not found, a blank white screen will be rendered.
    public init(
        authProvider: ParraAuthenticationProviderType,
        options: [ParraConfigurationOption] = [],
        appDelegateType: DelegateType.Type = ParraAppDelegate.self,
        launchScreenConfig: ParraLaunchScreen.Config? = nil,
        appContent: @MainActor @escaping () -> Content
    ) {
        self.authProvider = authProvider
        self.options = options
        self.appDelegateType = appDelegateType
        self.launchScreenConfig = launchScreenConfig
        self.appContent = appContent
    }

    // MARK: - Public

    public var body: some Scene {
        WindowGroup {
            ParraAppView(
                authProvider: authProvider,
                options: options,
                appDelegateType: appDelegateType,
                launchScreenConfig: launchScreenConfig,
                sceneContent: { _ in
                    appContent()
                }
            )
        }
    }

    // MARK: - Private

    private let authProvider: ParraAuthenticationProviderType
    private let options: [ParraConfigurationOption]
    private let appDelegateType: DelegateType.Type
    private let launchScreenConfig: ParraLaunchScreen.Config?
    private let appContent: () -> Content
}
