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
    let device: Device
    
    init(videoURL: URL, eyeTrackingData: [EyeTrackingData], device: Device) {
        self.videoURL = videoURL
        self.eyeTrackingData = eyeTrackingData
        self.device = device
    }
    
    
    func overlayEyeTrackingDataOnVideo(completion: @escaping (Result<URL, Error>) -> Void) async {
        // Load the video
        let videoAsset = AVAsset(url: videoURL)
        
        do {
            // Get the video track
            guard let videoTrack = try await videoAsset.loadTracks(withMediaType: .video).first else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Video track not found"])))
                return
            }
            
            // Get the video size from the track's naturalSize
            let videoSize = try await videoTrack.load(.naturalSize)
            
            // Get the frame rate of the video
            let frameRate = try await videoTrack.load(.nominalFrameRate)
            
            // Create a video composition
            let videoComposition = AVMutableVideoComposition(propertiesOf: videoAsset)
            videoComposition.renderSize = videoSize
            videoComposition.frameDuration = CMTime(value: 1, timescale: Int32(frameRate)) // Adjust the timescale to match your video's frame rate
            
            // Create an overlay layer
            let overlayLayer = CALayer()
            overlayLayer.frame = CGRect(x: 0, y: 0, width: videoComposition.renderSize.width, height: videoComposition.renderSize.height)
            
            // Add the overlay to the video composition
            videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: overlayLayer, in: overlayLayer)
            
            // Find the time of the first eye tracking data point
            guard let firstTimestamp = self.eyeTrackingData.first?.timestamp else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No eye tracking data available"])))
                return
            }
            
            // Create a sublayer for each data point
            for i in 0..<self.eyeTrackingData.count {
                let data = self.eyeTrackingData[i]
                let dotLayer = CALayer()
                
                let dotSize = CGSize(width: 20, height: 20) // Adjust the dot size as needed
                
                // Calculate the dot position based on the eye tracking data
                let dotOrigin = CGPoint(x: data.position.x * videoSize.width, y: (1 - data.position.y) * videoSize.height)
                
                let dotFrame = CGRect(origin: dotOrigin, size: dotSize)
                dotLayer.frame = dotFrame
                
                dotLayer.cornerRadius = dotSize.width / 2
                dotLayer.masksToBounds = true // Clip to bounds
                
                dotLayer.backgroundColor = UIColor.blue.cgColor // Change to the color you want for the dot
                
                // Check if dotLayer is within the overlayLayer
                if !overlayLayer.bounds.intersects(dotLayer.frame) {
                    print("Warning: dotLayer frame is outside of overlayLayer bounds")
                }
                
                // Add the dot layer to the overlay layer
                overlayLayer.addSublayer(dotLayer)
                
                // Create an animation to move the dot to the next position
                if i < self.eyeTrackingData.count - 1 {
                    let nextData = self.eyeTrackingData[i + 1]
                    let animation = CABasicAnimation(keyPath: "position")
                    
                    // Convert to video size
                    let floatX = (data.position.x / device.phoneScreenPointSize.width) * (videoSize.width)
                    let floatY = (videoSize.height) - (data.position.y / device.phoneScreenPointSize.height) * (videoSize.height)
                    let nextFloatX = (nextData.position.x / device.phoneScreenPointSize.width) * (videoSize.width)
                    let nextFloatY = (videoSize.height) - (nextData.position.y / device.phoneScreenPointSize.height) * (videoSize.height)
                    
                    // Set the animation properties
                    animation.fromValue = NSValue(cgPoint: CGPoint(x: floatX, y: floatY))
                    animation.toValue = NSValue(cgPoint: CGPoint(x: nextFloatX, y: nextFloatY))
                    
                    // Calculate the frame numbers
                    let currentFrameNumber = Int(round((data.timestamp - firstTimestamp) * Double(frameRate)))
                    let nextFrameNumber = Int(round((nextData.timestamp - firstTimestamp) * Double(frameRate)))
                    
                    // Calculate the begin time using the presentation time stamp
                    let beginTime = CMTime(value: Int64(currentFrameNumber), timescale: Int32(frameRate)).seconds

                    // Set the animation begin time
                    animation.beginTime = beginTime

                    // Set the duration
                    let duration = CGFloat(nextData.timestamp - data.timestamp)
                    animation.duration = CMTime(value: Int64(duration * Double(frameRate)), timescale: Int32(frameRate)).seconds
                    
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
        catch {
            completion(.failure(error))
        }
    }
}
