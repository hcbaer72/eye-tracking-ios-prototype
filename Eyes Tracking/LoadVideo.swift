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
        do {
            // Check if eye tracking data is available
            guard !eyeTrackingData.isEmpty else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No eye tracking data available"])))
                return
            }
            
            // Load the video
            let videoAsset = AVAsset(url: videoURL)
            
            // Get the video track
            guard let videoTrack = try await getVideoTrack(from: videoAsset) else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Video track not found"])))
                return
            }
            
            
            // Get the video size from the track's naturalSize
            let videoSize = try await getVideoSize(from: videoTrack)
            
            // Get the frame rate of the video
            let frameRate = try await getFrameRate(from: videoTrack)
            
            // Create a video composition
            let videoComposition = createVideoComposition(videoAsset: videoAsset, videoSize: videoSize, frameRate: frameRate)
            
            let syncedEyeTrackingData = try await syncEyeTrackingDataWithVideo(videoURL: videoURL, eyeTrackingData: eyeTrackingData)
            
            let overlayLayer = createOverlayLayer(with: videoSize, syncedEyeTrackingData: syncedEyeTrackingData, videoSize: videoSize, frameRate: frameRate, firstTimestamp: syncedEyeTrackingData[0].timestamp)
            
            let parentLayer = createParentLayer(videoSize: videoSize)
            // Create a parent layer containing the video layer and the overlay layer
            let videoLayer = CALayer()
            videoLayer.frame = parentLayer.frame
            
            parentLayer.addSublayer(videoLayer)
            parentLayer.addSublayer(overlayLayer)
            
            // Add the overlay to the video composition
            videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayers: [videoLayer], in: parentLayer)
            
            // Create an export session
            guard let exportSession = createExportSessionWithOutputURL(videoAsset: videoAsset, videoComposition: videoComposition) else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not create AVAssetExportSession"])))
                return
            }
            
            
            // Export the video
            exportSession.exportAsynchronously {
                switch exportSession.status {
                case .completed:
                    completion(.success(exportSession.outputURL!))
                case .failed, .cancelled:
                    if let error = exportSession.error {
                        completion(.failure(error))
                    }
                default:
                    break
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    func syncEyeTrackingDataWithVideo(videoURL: URL, eyeTrackingData: [EyeTrackingData]) -> [EyeTrackingData] {
        guard let eyeTrackingDataStartTimestamp = eyeTrackingData.first?.timestamp else {
            print("Eye tracking data is empty")
            return []
        }
        print("Eye tracking data start timestamp: \(eyeTrackingDataStartTimestamp)")

        let syncedEyeTrackingData = eyeTrackingData.map { data in
            let adjustedTimestamp = data.timestamp - eyeTrackingDataStartTimestamp
            return EyeTrackingData(position: data.position, timestamp: adjustedTimestamp)
        }
        return syncedEyeTrackingData
    }
}
    
extension EyeTrackingOverlayManager {
    func getVideoTrack(from asset: AVAsset) async throws -> AVAssetTrack? {
        let videoTracks = try await asset.loadTracks(withMediaType: .video)
        return videoTracks.first
    }
    
    func getVideoSize(from videoTrack: AVAssetTrack) async throws -> CGSize {
        return try await videoTrack.load(.naturalSize)
    }
    
    func getFrameRate(from videoTrack: AVAssetTrack) async throws -> Float {
        return try await videoTrack.load(.nominalFrameRate)
    }
    
    func createVideoComposition(videoAsset: AVAsset, videoSize: CGSize, frameRate: Float) -> AVMutableVideoComposition {
        let videoComposition = AVMutableVideoComposition(propertiesOf: videoAsset)
        videoComposition.renderSize = videoSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: Int32(frameRate))
        return videoComposition
    }
    
    func createOverlayLayer(with size: CGSize, syncedEyeTrackingData: [EyeTrackingData], videoSize: CGSize, frameRate: Float, firstTimestamp: TimeInterval) -> CALayer {
        let overlayLayer = CALayer()
        overlayLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)

        guard !syncedEyeTrackingData.isEmpty else {
            return overlayLayer
        }

        // Create only one dot layer
        let dotLayer = createDotLayer(with: syncedEyeTrackingData[0].position, videoSize: videoSize)

        // Add the dot layer to the overlay layer
        overlayLayer.addSublayer(dotLayer)

        for i in 0..<syncedEyeTrackingData.count - 1 {
            let data = syncedEyeTrackingData[i]
            let nextData = syncedEyeTrackingData[i + 1]

            let animation = createDotAnimation(from: data, to: nextData, videoSize: videoSize, frameRate: frameRate, firstTimestamp: firstTimestamp)
            
            // Add the animation to the dot layer
            dotLayer.add(animation, forKey: "position\(i)") // Unique key for each animation
        }

        return overlayLayer
    }

    
    func createDotLayer(with position: CGPoint, videoSize: CGSize) -> CALayer {
        let dotSize = CGSize(width: 20, height: 20) // Adjust the dot size as needed
        
        // Calculate the dot position based on the eye tracking data
        let floatX = (position.x / device.phoneScreenPointSize.width) * videoSize.width
        let floatY = videoSize.height - (position.y / device.phoneScreenPointSize.height) * videoSize.height
        let dotOrigin = CGPoint(x: floatX, y: floatY)
        
        let dotLayer = CALayer()
        dotLayer.frame = CGRect(origin: dotOrigin, size: dotSize)
        dotLayer.cornerRadius = dotSize.width / 2
        dotLayer.masksToBounds = true // Clip to bounds
        dotLayer.backgroundColor = UIColor.blue.cgColor // Change to the color you want for the dot
        
        return dotLayer
    }
    
    func addDotLayers(to overlayLayer: CALayer, syncedEyeTrackingData: [EyeTrackingData], videoSize: CGSize, frameRate: Float) {
        guard !syncedEyeTrackingData.isEmpty else {
            return
        }
        
        let firstTimestamp = syncedEyeTrackingData[0].timestamp
        
        for i in 0..<syncedEyeTrackingData.count - 1 {
            let data = syncedEyeTrackingData[i]
            let nextData = syncedEyeTrackingData[i + 1]
            
            // Create dot layers only for the next positions
            let dotLayer = createDotLayer(with: nextData.position, videoSize: videoSize)
            // Add the dot layer to the overlay layer
            overlayLayer.addSublayer(dotLayer)
            
            let animation = createDotAnimation(from: data, to: nextData, videoSize: videoSize, frameRate: frameRate, firstTimestamp: firstTimestamp)
            dotLayer.add(animation, forKey: "position")
        }
    }
    
    func createDotAnimation(from currentData: EyeTrackingData, to nextData: EyeTrackingData, videoSize: CGSize, frameRate: Float, firstTimestamp: TimeInterval) -> CABasicAnimation {
        let dotLayerAnimation = CABasicAnimation(keyPath: "position")

        let currentDotPosition = calculateDotPosition(for: currentData.position, videoSize: videoSize)
        let nextDotPosition = calculateDotPosition(for: nextData.position, videoSize: videoSize)

        dotLayerAnimation.fromValue = NSValue(cgPoint: currentDotPosition)
        dotLayerAnimation.toValue = NSValue(cgPoint: nextDotPosition)

        let currentFrameNumber = Int(round((currentData.timestamp - firstTimestamp) * Double(frameRate)))
        let nextFrameNumber = Int(round((nextData.timestamp - firstTimestamp) * Double(frameRate)))

        let beginTime = CMTime(value: Int64(currentFrameNumber), timescale: Int32(frameRate)).seconds
        dotLayerAnimation.beginTime = beginTime
        
        let duration = CGFloat(nextData.timestamp - currentData.timestamp)
        dotLayerAnimation.duration = CMTime(value: Int64(duration * Double(frameRate)), timescale: Int32(frameRate)).seconds
        
        dotLayerAnimation.fillMode = .forwards
        dotLayerAnimation.isRemovedOnCompletion = false
        
        return dotLayerAnimation
    }
        
        func calculateDotPosition(for position: CGPoint, videoSize: CGSize) -> CGPoint {
            let floatX = (position.x / device.phoneScreenPointSize.width) * videoSize.width
            let floatY = videoSize.height - (position.y / device.phoneScreenPointSize.height) * videoSize.height
            return CGPoint(x: floatX, y: floatY)
        }
        
    func createParentLayer(videoSize: CGSize) -> CALayer {
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
        videoLayer.frame = parentLayer.frame
        parentLayer.addSublayer(videoLayer)
        return parentLayer
    }
        
        func generateOutputURL() -> URL {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
            let filename = "OverlayVideo-\(dateFormatter.string(from: Date())).mov"
            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
            return outputURL
        }
        
        func createExportSessionWithOutputURL(videoAsset: AVAsset, videoComposition: AVMutableVideoComposition) -> AVAssetExportSession? {
            let outputURL = generateOutputURL()
            guard let exportSession = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetHighestQuality) else {
                return nil
            }
            exportSession.videoComposition = videoComposition
            exportSession.outputURL = outputURL
            exportSession.outputFileType = .mov
            return exportSession
        }
    
        
    }


    

