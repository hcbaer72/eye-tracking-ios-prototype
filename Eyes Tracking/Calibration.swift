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
//low pass filter?
//add bear in middle
//add calibration data
//add clearning calibration option / saving

enum CalibrationPhase {
    case notStarted
    case upperLeft
    case upperRight
    case lowerLeft
    case lowerRight
    case done
}

class CalibrationBearView: UIView {
    let progressLabel: UILabel = UILabel()
    // Add any other properties and UI elements you need for the calibration bear view
}


public class CalibrationManager {
    struct CalibrationOffset {
        var upperLeftOffset: CGPoint = .zero
        var upperRightOffset: CGPoint = .zero
        var lowerLeftOffset: CGPoint = .zero
        var lowerRightOffset: CGPoint = .zero
    }
    
    // Variables for calibration
    var calibrationPercent: CGFloat = 0.0
    var calibrationThreshold: CGFloat = 100.0

    var calibrationOffset = CalibrationOffset()
    
    weak var viewController: ViewController?
    var fixationStartTime: CFTimeInterval? // Declare fixation start time as an instance variable

    var calibrationPhase: CalibrationPhase = .notStarted
    var calibrationViews: [CalibrationPhase: UIView] = [:]

    var calibrationLabels: [CalibrationPhase: UILabel] = [:]

    init(viewController: ViewController) {
        self.viewController = viewController

        self.calibrationViews = [
            .upperLeft: viewController.upperLeftCornerBear,
            .upperRight: viewController.upperRightCornerBear,
            .lowerLeft: viewController.lowerLeftCornerBear,
            .lowerRight: viewController.lowerRightCornerBear
        ]

        self.calibrationLabels = [
            .upperLeft: viewController.upperLeftCornerBearLabel,
            .upperRight: viewController.upperRightCornerBearLabel,
            .lowerLeft: viewController.lowerLeftCornerBearLabel,
            .lowerRight: viewController.lowerRightCornerBearLabel
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
            let rawEyePosition = eyePositionIndicatorView.center
            let calibrationBearPosition = bear.center

            // Check if fixation occurred in the current calibration area
            let fixationOccurred = checkFixationOccurred(rawEyePosition: rawEyePosition, calibrationBearPosition: calibrationBearPosition)

            // Update the calibration percentage label based on fixation occurrence
            let calibrationPercentage: CGFloat = fixationOccurred ? 1.0 : 0.0
            updateBearCalibrationPercentage(phase: calibrationPhase, percentage: calibrationPercentage)

            if fixationOccurred {
                calibrationPercent += 1.0
                if calibrationPercent >= calibrationThreshold {
                    // Calibration for the current quadrant is complete
                    calibrationPercent = 0.0
                    switch calibrationPhase {
                    case .upperLeft:
                        calibrationOffset.upperLeftOffset = calculateCalibrationOffset(rawEyePosition: rawEyePosition, calibrationBearPosition: calibrationBearPosition)
                        calibrationPhase = .upperRight
                        showBear(corner: .upperRight)
                    case .upperRight:
                        calibrationOffset.upperRightOffset = calculateCalibrationOffset(rawEyePosition: rawEyePosition, calibrationBearPosition: calibrationBearPosition)
                        calibrationPhase = .lowerLeft
                        showBear(corner: .lowerLeft)
                    case .lowerLeft:
                        calibrationOffset.lowerLeftOffset = calculateCalibrationOffset(rawEyePosition: rawEyePosition, calibrationBearPosition: calibrationBearPosition)
                        calibrationPhase = .lowerRight
                        showBear(corner: .lowerRight)
                    case .lowerRight:
                        calibrationOffset.lowerRightOffset = calculateCalibrationOffset(rawEyePosition: rawEyePosition, calibrationBearPosition: calibrationBearPosition)
                        calibrationPhase = .done
                        hideAllBears()
                    default:
                        break
                    }
                }
            } else {
                calibrationPercent = 0.0 // Reset calibration percent if fixation is lost
            }

            // Adjust the eye position indicator using the calibration offset
            let adjustedX = rawEyePosition.x - getAdjustedOffsetForPhase().x
            let adjustedY = rawEyePosition.y - getAdjustedOffsetForPhase().y
            let adjustedEyePosition = CGPoint(x: adjustedX, y: adjustedY)

            // Use the adjusted eye position for further calculations or display
            // ...
        }
    }

    func calculateCalibrationOffset(rawEyePosition: CGPoint, calibrationBearPosition: CGPoint) -> CGPoint {
        let xOffset = calibrationBearPosition.x - rawEyePosition.x
        let yOffset = calibrationBearPosition.y - rawEyePosition.y
        return CGPoint(x: xOffset, y: yOffset)
    }

    func getAdjustedEyePosition(rawEyePosition: CGPoint) -> CGPoint {
        let adjustedX = rawEyePosition.x + getAdjustedOffsetForPhase().x
        let adjustedY = rawEyePosition.y + getAdjustedOffsetForPhase().y
        
        return CGPoint(x: adjustedX, y: adjustedY)
    }
    

    func updateBearDisplay(bear: CalibrationBearView, fixationOccurred: Bool) {
           let progressText = fixationOccurred ? "100%" : "0%"
           bear.progressLabel.text = progressText
           // Update any other display elements of the bear
       }
    
    func getAdjustedOffsetForPhase() -> CGPoint {
          switch calibrationPhase {
          case .upperLeft:
              return calibrationOffset.upperLeftOffset
          case .upperRight:
              return calibrationOffset.upperRightOffset
          case .lowerLeft:
              return calibrationOffset.lowerLeftOffset
          case .lowerRight:
              return calibrationOffset.lowerRightOffset
          default:
              return .zero
          }
      }
    
    func checkFixationOccurred(rawEyePosition: CGPoint, calibrationBearPosition: CGPoint) -> Bool {
        let distanceThreshold: CGFloat = 10.0 // Set a distance threshold for fixation
        let durationThreshold: CFTimeInterval = 3.0 // Set a duration threshold for fixation in seconds
        
        let distance = sqrt(pow(rawEyePosition.x - calibrationBearPosition.x, 2) + pow(rawEyePosition.y - calibrationBearPosition.y, 2))
        
        if distance <= distanceThreshold {
            // Eye position is within the distance threshold
            // Check the duration of fixation
            
            if calibrationPhase == .notStarted {
                // Start of fixation in the current calibration phase
                // Store the start time of fixation
                fixationStartTime = CACurrentMediaTime()
            } else if let fixationStartTime = fixationStartTime {
                // Check if fixation duration exceeds the threshold
                let currentTime = CACurrentMediaTime()
                let fixationDuration = currentTime - fixationStartTime
                
                if fixationDuration >= durationThreshold {
                    // Fixation occurred for the required duration
                    return true
                }
                
                // Calculate calibration percentage
                let calibrationPercentage = min(1.0, fixationDuration / durationThreshold)
                updateBearCalibrationPercentage(phase: calibrationPhase, percentage: calibrationPercentage)
            }
        } else {
            // Eye position moved outside the distance threshold
            // Reset the start time for fixation
            fixationStartTime = nil
            
            // Reset the calibration percentage for the bear
            updateBearCalibrationPercentage(phase: calibrationPhase, percentage: 0.0)

        }
        
        return false
    }
    
    func updateBearCalibrationPercentage(phase: CalibrationPhase, percentage: CGFloat) {
        calibrationLabels[phase]?.text = "\(Int(percentage * 100))%" // Update the corresponding label with the calibration percentage
    }

}
