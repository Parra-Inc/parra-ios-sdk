//
//  ParraOrientation.swift
//  Parra
//
//  Created by Mick MacCallum on 6/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import UIKit

public enum ParraOrientation {
    public static var orientationLock = UIInterfaceOrientationMask.all {
        didSet {
            let isPortrait = orientationLock == .portrait || orientationLock ==
                .portraitUpsideDown
            let isLandscape = orientationLock == .landscapeLeft ||
                orientationLock == .landscapeRight
            let isSingleOrientation = isPortrait || isLandscape

            if isSingleOrientation, let windowScene =
                UIApplication.shared.connectedScenes.first as? UIWindowScene
            {
                windowScene.requestGeometryUpdate(
                    .iOS(interfaceOrientations: orientationLock)
                )
            }

            UIViewController.topMostViewController()?
                .setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }
}
