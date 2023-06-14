//
//  Calibration.swift
//  Eyes Tracking
//
//  Created by holly on 6/13/23.
//  Copyright © 2023 virakri. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI


//add fixation identification before interpolating?

enum CalibrationPhase {
    case notStarted
    case upperLeft
    case upperRight
    case lowerLeft
    case lowerRight
    case done
}

public class CalibrationManager {
    
    struct CalibrationOffset {
        var xOffset: CGFloat = 0.0
        var yOffset: CGFloat = 0.0
    }

    var calibrationOffset = CalibrationOffset()
    
    weak var viewController: ViewController?
    
    var calibrationViews: [CalibrationPhase: UIView] = [:]
    var calibrationPhase: CalibrationPhase = .notStarted
    
    init(viewController: ViewController) {
        self.viewController = viewController
        self.calibrationViews = [
            .upperLeft: viewController.upperLeftCornerBear!,
            .upperRight: viewController.upperRightCornerBear!,
            .lowerLeft: viewController.lowerLeftCornerBear!,
            .lowerRight: viewController.lowerRightCornerBear!
        ]
    }
    
    func startCalibration() {
        calibrationPhase = .upperLeft
        showBear(corner: .upperLeft)
    }

    func showBear(corner: CalibrationPhase) {
        guard let view = calibrationViews[corner] else { return }
        view.isHidden = false
        viewController?.view.bringSubviewToFront(view)
    }

    func hideAllBears() {
        calibrationViews.values.forEach { $0.isHidden = true }
    }
    
    func buttonPressed() {
        if calibrationPhase == .notStarted {
            // Start the calibration
            startCalibration()
        } else if calibrationPhase != .done {
            // Hide the current bear
            guard let currentBear = calibrationViews[calibrationPhase] else { return }
            currentBear.isHidden = true

            // Proceed to the next calibration phase
            switch calibrationPhase {
            case .upperLeft:
                calibrationPhase = .upperRight
                showBear(corner: .upperRight)
            case .upperRight:
                calibrationPhase = .lowerLeft
                showBear(corner: .lowerLeft)
            case .lowerLeft:
                calibrationPhase = .lowerRight
                showBear(corner: .lowerRight)
            case .lowerRight:
                calibrationPhase = .done
                hideAllBears()
            default:
                break
            }
        }
    }

    func updateEyeTracking(_ eyePositionIndicatorView: UIView) {
        if calibrationPhase != .notStarted && calibrationPhase != .done,
           let bear = calibrationViews[calibrationPhase] {
            // Get the estimated eye positions from the eye tracker
            let rawEyePosition = eyePositionIndicatorView.center
            
            // Get the position of the calibration bear
            let calibrationBearPosition = bear.center
            
            // Calculate the calibration offset
            let xOffset = calibrationBearPosition.x - rawEyePosition.x
            let yOffset = calibrationBearPosition.y - rawEyePosition.y
            calibrationOffset = CalibrationOffset(xOffset: xOffset, yOffset: yOffset)
            
            // Proceed to the next calibration phase
            switch calibrationPhase {
            case .upperLeft:
                calibrationPhase = .upperRight
                showBear(corner: .upperRight)
            case .upperRight:
                calibrationPhase = .lowerLeft
                showBear(corner: .lowerLeft)
            case .lowerLeft:
                calibrationPhase = .lowerRight
                showBear(corner: .lowerRight)
            case .lowerRight:
                calibrationPhase = .done
                hideAllBears()
            default:
                break
            }
            
            // Adjust the eye position indicator using the calibration offset
            let adjustedX = rawEyePosition.x + calibrationOffset.xOffset
            let adjustedY = rawEyePosition.y + calibrationOffset.yOffset
            let adjustedEyePosition = CGPoint(x: adjustedX, y: adjustedY)
            print(adjustedEyePosition)
            // Use the adjusted eye position for further calculations or display
            // ...
        }
    }


    func getAdjustedEyePosition(rawEyePosition: CGPoint) -> CGPoint {
        let adjustedX = rawEyePosition.x + calibrationOffset.xOffset
        let adjustedY = rawEyePosition.y + calibrationOffset.yOffset
        
        return CGPoint(x: adjustedX, y: adjustedY)
    }
}
