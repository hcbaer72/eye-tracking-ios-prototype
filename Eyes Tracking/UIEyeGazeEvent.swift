//
//  UIEyeGazeEvent.swift
//  Eyes Tracking
//
//  Created by Kristen Lineback on 3/19/23.
//  Copyright © 2023 virakri. All rights reserved.
//

import Foundation
import UIKit

class UIEyeGazeEvent: UIEvent {
    public var allGazes: Set<UIEyeGaze>?
    override var allTouches: Set<UITouch>? {
        return allGazes
    }

    /**
     The time when the event occurred
     */
    private var _timestamp: TimeInterval
    
    /**
     Returns the time when the event occurred
     */
    public var timeStamp: TimeInterval {
        return _timestamp
    }
    
    init(allGazes: Set<UIEyeGaze>? = nil) {
        self.allGazes = allGazes
        self._timestamp = Date().timeIntervalSince1970
    }
}
