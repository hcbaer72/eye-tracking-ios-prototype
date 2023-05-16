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
        let videoSize = CGSize(width: 1920, height: 1080) // Replace with your desired size

        // Create a video composition
        let videoComposition = AVMutableVideoComposition(propertiesOf: videoAsset)
        videoComposition.renderSize = videoSize

        // Create an overlay layer
        let overlayLayer = CALayer()
        overlayLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)

        // Add the overlay to the video composition
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: overlayLayer, in: overlayLayer)

        
        // Create a sublayer for each data point
            // Create a sublayer for each data point
            for i in 0..<self.eyeTrackingData.count {
                let data = self.eyeTrackingData[i]
                let dotLayer = CALayer()
                dotLayer.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
                dotLayer.position = data.position
                dotLayer.cornerRadius = dotLayer.bounds.width / 2
                dotLayer.backgroundColor = UIColor.red.cgColor
                overlayLayer.addSublayer(dotLayer)
                
                // Create an animation to move the dot to the next position
                if i < self.eyeTrackingData.count - 1 {
                    let nextData = self.eyeTrackingData[i + 1]
                    let animation = CABasicAnimation(keyPath: "position")
                    animation.fromValue = NSValue(cgPoint: data.position)
                    animation.toValue = NSValue(cgPoint: nextData.position)
                    animation.beginTime = data.timestamp
                    animation.duration = nextData.timestamp - data.timestamp
                    animation.fillMode = .forwards
                    animation.isRemovedOnCompletion = false
                    dotLayer.add(animation, forKey: "position")
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
