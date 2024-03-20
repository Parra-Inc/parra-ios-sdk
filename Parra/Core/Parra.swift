//
//  Parra.swift
//  Parra
//
//  Created by Michael MacCallum on 11/22/21.
//

import Foundation
import UIKit

private let logger = Logger(category: "Parra")

/// The primary module used to interact with the Parra SDK.
/// Access this module via the `parra` `@Environment` object in SwiftUI after wrapping your `Scene`
/// in the ``ParraApp`` View.

public class Parra: Observable {
    // MARK: - Lifecycle

    init(
        configuration: ParraConfiguration,
        dataManager: ParraDataManager,
        syncManager: ParraSyncManager,
        sessionManager: ParraSessionManager,
        networkManager: ParraNetworkManager,
        notificationCenter: NotificationCenterType,
        feedback: ParraFeedback
    ) {
        self.configuration = configuration
        self.dataManager = dataManager
        self.syncManager = syncManager
        self.sessionManager = sessionManager
        self.networkManager = networkManager
        self.notificationCenter = notificationCenter
        self.feedback = feedback

        self.globalComponentFactory = ComponentFactory(
            global: configuration.globalComponentAttributes,
            theme: configuration.theme
        )
    }

    deinit {
        removeEventObservers()
    }

    // MARK: - Public

    // MARK: - Parra Modules

    public let feedback: ParraFeedback

    // MARK: - Authentication

    /// Used to clear any cached credentials for the current user. After calling
    /// ``Parra/Parra/logout()``, the authentication provider you configured
    /// will be invoked the very next time the Parra API is accessed.
    public func logout() async {
        await syncManager.enqueueSync(with: .immediate)
        await dataManager.updateCredential(credential: nil)

        await syncManager.stopSyncTimer()
    }

    // MARK: - Synchronization

    /// Parra data is syncrhonized automatically. Use this method if you wish to
    /// trigger a synchronization event manually. This may be something you want
    /// to do in response to a significant event in your app, or in response to
    /// a low memory warning, for example. Note that in order to prevent
    /// excessive network activity it may take up to 30 seconds for the sync to
    /// complete after being initiated.
    public func triggerSync() async {
        // Uploads any cached Parra data. This includes data like answers to
        // questions. Don't expose sync mode publically.
        await syncManager.enqueueSync(with: .eventual)
    }

    // MARK: - Theme

    public func updateTheme(to newTheme: ParraTheme) {
        let oldTheme = configuration.theme
        configuration.theme = newTheme

        globalComponentFactory = ComponentFactory(
            global: configuration.globalComponentAttributes,
            theme: newTheme
        )

        notificationCenter.post(
            name: Parra.themeWillChangeNotification,
            object: nil,
            userInfo: [
                "oldTheme": oldTheme,
                "newTheme": newTheme
            ]
        )
    }

    // MARK: - Internal

    // MARK: - Statics

    /// Only change this if you change the module name in the Xcode project.
    static let moduleName = "Parra"
    static let errorDomain = "com.parra.error"

    private(set) var configuration: ParraConfiguration

    // MARK: - Managers

    let dataManager: ParraDataManager
    let syncManager: ParraSyncManager

    @usableFromInline let sessionManager: ParraSessionManager
    let networkManager: ParraNetworkManager
    let notificationCenter: NotificationCenterType

    private(set) var globalComponentFactory: ComponentFactory

    private(set) lazy var eventPrefix =
        "parra:\(Self.moduleName.lowercased())"

    static func bundle() -> Bundle {
        return Bundle(for: self as AnyClass)
    }

    static func libraryVersion() -> String {
        return bundle()
            .infoDictionary?["CFBundleShortVersionString"] as? String ??
            "unknown"
    }

    @MainActor
    func initialize(
        with authProvider: ParraAuthenticationProviderType
    ) async {
        let authProviderFunction = authProvider.getProviderFunction(
            using: networkManager,
            onAuthenticationRefresh: { [weak self] success in
                guard let self else {
                    return
                }

                if success {
                    addEventObservers()

                    syncManager.startSyncTimer()
                } else {
                    removeEventObservers()

                    await dataManager.updateCredential(credential: nil)
                    syncManager.stopSyncTimer()
                }
            }
        )

        await sessionManager.initializeSessions()
        networkManager
            .updateAuthenticationProvider(authProviderFunction)

        logger.info("Parra SDK Initialized")

        do {
            _ = try await networkManager.refreshAuthentication()

            performPostAuthRefreshActions()
        } catch {
            logger.error(
                "Authentication handler in call to Parra.initialize failed",
                error
            )
        }
    }

    // MARK: - Private

    @MainActor
    private func performPostAuthRefreshActions() {
        logger.debug("Performing push authentication refresh actions.")

        if configuration.pushNotificationsEnabled {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}
