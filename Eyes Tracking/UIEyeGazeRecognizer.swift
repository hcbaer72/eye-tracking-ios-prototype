//
//  UIEyeGazeRecognizer.swift
//  Eyes Tracking
//
//  Created by Kristen Lineback on 3/19/23.
//  Copyright © 2023 virakri. All rights reserved.
//

import Foundation
import UIKit.UIGestureRecognizerSubclass

class UIEyeGazeRecognizer: UIGestureRecognizer {

    func gazeBegan(_ gaze: UIEyeGaze, with event: UIEyeGazeEvent?) {
        // No-op
    }

    func gazeMoved(_ gaze: UIEyeGaze, with event: UIEyeGazeEvent?) {
        // No-op
    }

    func gazeEnded(_ gaze: UIEyeGaze, with event: UIEyeGazeEvent?) {
        // No-op
    }

    func gazeCancelled(_ gaze: UIEyeGaze, with event: UIEyeGazeEvent?) {
        // No-op
    }

}
