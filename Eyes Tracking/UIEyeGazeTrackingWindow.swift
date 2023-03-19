//
//  UIEyeGazeTrackingWindow.swift
//  Eyes Tracking
//
//  Created by Kristen Lineback on 3/19/23.
//  Copyright © 2023 virakri. All rights reserved.
//

import UIKit

final class UIHeadGazeTrackingWindow: UIWindow {

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        self.rootViewController = ViewController()
    }
}
