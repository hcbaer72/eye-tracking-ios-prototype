//
//  EyeTrackingDataAnalysis.swift
//  Eyes Tracking
//
//  Created by holly on 5/31/23.
//  Copyright © 2023 virakri. All rights reserved.
//

import Foundation

struct FixationData {
    let center: CGPoint
    let duration: TimeInterval
    let startTime: TimeInterval // Timestamp when the fixation starts
}

extension ViewController {
    func saveEyeTrackingFixations() {
        // Check if there is eye tracking data available
        guard !eyeTrackingData.isEmpty else {
            print("No eye tracking data available.")
            return
        }
        
        // Sort the eye tracking data by timestamp
        let sortedData = eyeTrackingData.sorted { $0.timestamp < $1.timestamp }
        
        // Define fixation analysis parameters
        let fixationDurationThreshold: TimeInterval = 0.5 // Minimum duration for a fixation (in seconds)
        let maxFixationDistance: CGFloat = 50.0 // Maximum distance between consecutive eye positions for a fixation (in points)
        
        // Perform fixation analysis
        var fixations: [FixationData] = []
        var currentFixationStartIndex = 0
        var previousPosition = sortedData[0].position
        
        for i in 1..<sortedData.count {
            let currentPosition = sortedData[i].position
            let distance = CGPoint.distance(from: previousPosition, to: currentPosition)
            
            if distance > maxFixationDistance {
                let fixationStartTime = sortedData[currentFixationStartIndex].timestamp
                let fixationDuration = sortedData[i - 1].timestamp - fixationStartTime
                
                if fixationDuration >= fixationDurationThreshold {
                    let fixationCenter = calculateFixationCenter(startIndex: currentFixationStartIndex, endIndex: i - 1)
                    let fixation = FixationData(center: fixationCenter, duration: fixationDuration, startTime: fixationStartTime)
                    fixations.append(fixation)
                }
                
                currentFixationStartIndex = i
            }
            
            previousPosition = currentPosition
        }
        
        // Write fixation analysis to a new file
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let filename = "FixationAnalysis-\(dateFormatter.string(from: Date())).txt"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
        
        var analysisString = "Fixation Duration Analysis:\n\n"

        for (index, fixation) in fixations.enumerated() {
            analysisString += "Fixation \(index + 1):\n"
            analysisString += "Start Time: \(fixation.startTime)\n" // Include start time
            analysisString += "Duration: \(fixation.duration) seconds\n"
            analysisString += "Center: (\(fixation.center.x), \(fixation.center.y))\n\n"
        }

        do {
            try analysisString.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Fixation analysis saved to file: \(filename)")
        } catch {
            print("Error saving fixation analysis: \(error.localizedDescription)")
        }
    }
    
    private func calculateFixationCenter(startIndex: Int, endIndex: Int) -> CGPoint {
        var totalX: CGFloat = 0.0
        var totalY: CGFloat = 0.0
        
        for i in startIndex...endIndex {
            totalX += eyeTrackingData[i].position.x
            totalY += eyeTrackingData[i].position.y
        }
        
        let count = CGFloat(endIndex - startIndex + 1)
        return CGPoint(x: totalX / count, y: totalY / count)
    }
}

extension CGPoint {
    static func distance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        let dx = point2.x - point1.x
        let dy = point2.y - point1.y
        return sqrt(dx * dx + dy * dy)
    }
}
