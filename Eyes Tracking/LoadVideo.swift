//
//  LoadVideo.swift
//  Eyes Tracking
//
//  Created by holly on 5/16/23.
//  Copyright © 2023 virakri. All rights reserved.
//

import Foundation
import AVFoundation
import CoreAnimation

class EyeTrackingOverlayManager {

    let videoURL: URL
    let eyeTrackingData: [EyeTrackingData]

    init(videoURL: URL, eyeTrackingData: [EyeTrackingData]) {
        self.videoURL = videoURL
        self.eyeTrackingData = eyeTrackingData
    }

    func overlayEyeTrackingDataOnVideo() {
        // Load the video
        let videoAsset = AVAsset(url: videoURL)

        // Create a video composition
        let videoComposition = AVMutableVideoComposition(propertiesOf: videoAsset)

        // Create an overlay layer
        let overlayLayer = CALayer()
        overlayLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)

        // Create a sublayer for each data point
        for data in eyeTrackingData {
            let dotLayer = CALayer()
            dotLayer.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
            dotLayer.position = data.position
            dotLayer.cornerRadius = dotLayer.bounds.width / 2
            dotLayer.backgroundColor = UIColor.red.cgColor
            overlayLayer.addSublayer(dotLayer)

            // Create an animation to move the dot to the next position
            if let nextData = eyeTrackingData.next(after: data) {
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
        let exportSession = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetHighestQuality)
        exportSession?.videoComposition = videoComposition
    }
}

