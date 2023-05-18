//
//  LoadVideo.swift
//  Eyes Tracking
//
//  Created by holly on 5/16/23.
//  Copyright © 2023 virakri. All rights reserved.
//

import Foundation
import AVFoundation
import QuartzCore
import UIKit


// let videoSize = CGSize(width: 1300, height: 1860)
//add heat map also?
//add workaround for negative position values



class EyeTrackingOverlayManager {
    
    let videoURL: URL
    let eyeTrackingData: [EyeTrackingData]
    
    init(videoURL: URL, eyeTrackingData: [EyeTrackingData]) {
        self.videoURL = videoURL
        self.eyeTrackingData = eyeTrackingData
    }
    
    func overlayEyeTrackingDataOnVideo(completion: @escaping (Result<URL, Error>) -> Void) {
        // Load the video
        let videoAsset = AVAsset(url: videoURL)
        
        // Define the video size
        let videoSize = CGSize(width: 1300, height: 1860) // Replace with your desired size
        
        // Create a video composition
        let videoComposition = AVMutableVideoComposition(propertiesOf: videoAsset)
        videoComposition.renderSize = videoSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30) // Adjust the timescale to match your video's frame rate
        
        // Create an overlay layer
        let overlayLayer = CALayer()
        overlayLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
        
        // Add the overlay to the video composition
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: overlayLayer, in: overlayLayer)
        
        // Retrieve the start time from user defaults or the storage mechanism you used
        if let startTime = UserDefaults.standard.object(forKey: "ScreenRecordingStartTime") as? Date {
            // Find the time of the first eye tracking data point
            let firstTimestamp = eyeTrackingData.first?.timestamp ?? 0
            
            // Create a sublayer for each data point
            for i in 0..<eyeTrackingData.count {
                let data = eyeTrackingData[i]
                let dotLayer = CALayer()
                
                // Set the initial position of the dot layer
                dotLayer.frame = CGRect(x: data.position.x, y: data.position.y, width: 20, height: 20) // Adjust width and height as needed
                
                // Set other properties of the dot layer
                dotLayer.backgroundColor = UIColor.red.cgColor // Change to the color you want for the dot
                
                // Add the dot layer to the overlay layer
                overlayLayer.addSublayer(dotLayer)
                
                // Create an animation to move the dot to the next position
                if i < eyeTrackingData.count - 1 {
                    let nextData = eyeTrackingData[i + 1]
                    let animation = CABasicAnimation(keyPath: "position")
                    
                    // Convert the position to CGFloat
                    let floatX = CGFloat(data.position.x)
                    let floatY = CGFloat(data.position.y)
                    let nextFloatX = CGFloat(nextData.position.x)
                    let nextFloatY = CGFloat(nextData.position.y)
                    
                    // Set the animation properties
                    animation.fromValue = NSValue(cgPoint: CGPoint(x: floatX, y: floatY))
                    animation.toValue = NSValue(cgPoint: CGPoint(x: nextFloatX, y: nextFloatY))
                    
                    // Set the timestamp directly as the beginTime
                    animation.beginTime = startTime.timeIntervalSinceReferenceDate + firstTimestamp
                    
                    // Set the duration
                    let duration = nextData.timestamp - data.timestamp
                    animation.duration = duration
                    
                    animation.fillMode = .forwards
                    animation.isRemovedOnCompletion = true
                    dotLayer.add(animation, forKey: "position")
                }
            }
        }


        // Create a parent layer containing the video layer and the overlay layer
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
        videoLayer.frame = parentLayer.frame
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(overlayLayer)

        // Add the overlay to the video composition
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayers: [videoLayer], in: parentLayer)

        // Create an export session
        guard let exportSession = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetHighestQuality) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not create AVAssetExportSession"])))
            return
        }

        exportSession.videoComposition = videoComposition

        // Generate a unique filename with date and time prefix
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let filename = "OverlayVideo-\(dateFormatter.string(from: Date())).mov"

        // Output URL
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mov

        // Export the video
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                completion(.success(outputURL))
            case .failed, .cancelled:
                if let error = exportSession.error {
                    completion(.failure(error))
                }
            default:
                break
            }
        }
    }
}

