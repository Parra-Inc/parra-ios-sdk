//
//  ParraFeedbackSyncManager.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation
import UIKit

internal enum ParraSyncMode: String {
    case immediate
    case eventual
}

/// Manager used to facilitate the synchronization of Parra data stored locally with the Parra API.
internal actor ParraSyncManager {
    internal enum Constant {
        static let eventualSyncDelay: TimeInterval = 30.0
    }
    
    /// Whether or not a sync operation is in progress.
    internal private(set) var isSyncing = false
    
    /// Whether or not new attempts to sync occured while a sync was in progress. Many sync events could be received while a sync
    /// is in progress so we just track whether any happened. If any happen then we will perform a subsequent sync when the original
    /// is completed.
    internal private(set) var enqueuedSyncMode: ParraSyncMode? = nil
    
    private let networkManager: ParraNetworkManager
    private let sessionManager: ParraSessionManager

    @MainActor private var syncTimer: Timer?
    
    internal init(networkManager: ParraNetworkManager,
                  sessionManager: ParraSessionManager) {
        self.networkManager = networkManager
        self.sessionManager = sessionManager
    }
    
    /// Used to send collected data to the Parra API. Invoked automatically internally, but can be invoked externally as necessary.
    internal func enqueueSync(with mode: ParraSyncMode) async {
        guard networkManager.authenticationProvider != nil else {
            parraLogTrace("Skipping \(mode) sync. Authentication provider is unset.")

            return
        }

        guard await hasDataToSync() else {
            parraLogDebug("Skipping \(mode) sync. No sync necessary.")
            return
        }

        parraLogDebug("Enqueuing sync: \(mode)")

        if isSyncing {
            if mode == .immediate {
                parraLogDebug("Sync already in progress. Sync was requested immediately. Will sync again upon current sync completion.")
                
                enqueuedSyncMode = .immediate
            } else {
                parraLogDebug("Sync already in progress. Marking enqued sync.")
                
                if enqueuedSyncMode != .immediate {
                    // An enqueued eventual sync shouldn't override an enqueued immediate sync.
                    enqueuedSyncMode = .eventual
                }
            }
            
            return
        }
        
        Task {
            await self.sync()
        }
        
        parraLogDebug("Sync enqued")
    }
    
    private func sync() async {
        isSyncing = true
        
        let syncToken = UUID().uuidString
        
        NotificationCenter.default.post(
            name: Parra.syncDidBeginNotification,
            object: self,
            userInfo: [
                Parra.Constant.syncTokenKey: syncToken
            ]
        )
        
        defer {
            NotificationCenter.default.post(
                name: Parra.syncDidEndNotification,
                object: self,
                userInfo: [
                    Parra.Constant.syncTokenKey: syncToken
                ]
            )
        }
        
        guard await hasDataToSync() else {
            parraLogDebug("No data available to sync")
            isSyncing = false

            return
        }
        
        parraLogDebug("Starting sync")
        
        let start = CFAbsoluteTimeGetCurrent()
        parraLogTrace("Sending sync data...")

        await performSync()

        let duration = CFAbsoluteTimeGetCurrent() - start
        parraLogTrace("Sync data sent. Took \(duration)(s)")
        
        if let enqueuedSyncMode {
            parraLogDebug("More sync jobs were enqueued. Repeating sync.")
            
            self.enqueuedSyncMode = nil
            
            switch enqueuedSyncMode {
            case .immediate:
                await sync()
            default:
                break
            }
        } else {
            parraLogDebug("No more jobs found. Completing sync.")
            
            isSyncing = false
        }
    }

    private func performSync() async {
        for (_, module) in Parra.registeredModules {
            await module.synchronizeData()
        }
    }
    
    private func hasDataToSync() async -> Bool {
        var shouldSync = false
        for (_, module) in Parra.registeredModules {
            if await module.hasDataToSync() {
                shouldSync = true
                break
            }
        }
        
        return shouldSync
    }
    
    @MainActor internal func startSyncTimer() {
        stopSyncTimer()
        parraLogTrace("Starting sync timer")

        syncTimer = Timer.scheduledTimer(
            withTimeInterval: Constant.eventualSyncDelay,
            repeats: true
        ) { timer in
            parraLogTrace("Sync timer fired")

            Task {
                await self.enqueueSync(with: .immediate)
            }
        }
    }
    
    @MainActor internal func stopSyncTimer() {
        guard let syncTimer = syncTimer else {
            return
        }

        parraLogTrace("Stopping sync timer")

        syncTimer.invalidate()
        self.syncTimer = nil
    }
}
