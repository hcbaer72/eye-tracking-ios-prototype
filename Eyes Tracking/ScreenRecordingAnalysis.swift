//
//  ScreenRecordingAnalysis.swift
//  Eyes Tracking
//
//  Created by holly on 5/31/23.
//  Copyright © 2023 virakri. All rights reserved.
//

import Foundation
import AVFoundation
import Vision
import CoreML
import UIKit

/*
public struct RecognizedObject {
    let label: String
    let confidence: VNConfidence
    let boundingBox: CGRect
    
    init(label: String, confidence: VNConfidence, boundingBox: CGRect) {
        self.label = label
        self.confidence = confidence
        self.boundingBox = boundingBox
    }
}

class ObjectManager {
    let videoURL: URL
    let eyeTrackingData: [EyeTrackingData]
    
    init(videoURL: URL, eyeTrackingData: [EyeTrackingData]) {
        self.videoURL = videoURL
        self.eyeTrackingData = eyeTrackingData
    }
    
    func processEyeTrackingDataWithImageAnalysis(completion: @escaping (Result<URL, Error>) -> Void) async {
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
            
            // Generate output URL for the recognized objects file
            let outputURL = generateOutputURL()
            
            // Processed objects will be stored in this array
            var processedObjects: [RecognizedObject] = []
            
            for eyeTrackingPoint in eyeTrackingData {
                let videoFrameIndex = try await mapEyeTrackingPointToVideoFrame(eyeTrackingPoint: eyeTrackingPoint, videoTrack: videoTrack)
                
                guard let frame = try await loadFrame(at: videoFrameIndex, using: videoAsset) else {
                    continue
                }
                
                let recognizedObjects = await performObjectDetectionSync(on: frame, eyeTrackingData: eyeTrackingPoint, fileURL: outputURL)
                processedObjects.append(contentsOf: recognizedObjects)
            }
            
            // Processed objects are available in the `processedObjects` array
            for object in processedObjects {
                print("Recognized Object Label: \(object.label)")
                print("Confidence: \(object.confidence)")
                print("Bounding Box: \(object.boundingBox)")
                print("---")
            }
            
            completion(.success(outputURL))
        } catch {
            completion(.failure(error))
        }
    }
    
    func mapEyeTrackingPointToVideoFrame(eyeTrackingPoint: EyeTrackingData, videoTrack: AVAssetTrack) async throws -> Int {
        let eyeTrackingTimestamp = eyeTrackingPoint.timestamp
        guard let asset = videoTrack.asset else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid asset"])
        }
        let duration = try await asset.load(.duration)
        let timeScale = duration.timescale
        let time = CMTime(seconds: eyeTrackingTimestamp, preferredTimescale: timeScale)
        let videoFrameIndex = Int(time.value) / Int(time.timescale)
        return videoFrameIndex
    }
    
    func performObjectDetectionSync(on frame: CVPixelBuffer, eyeTrackingData: EyeTrackingData, fileURL: URL) async -> [RecognizedObject] {
        guard let modelURL = Bundle.main.url(forResource: "yolov3-tiny", withExtension: "mlmodelc") else {
            fatalError("Failed to locate the YOLOv3-Tiny model file.")
        }
        
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let objectDetectionRequest = VNCoreMLRequest(model: visionModel) { request, error in
                guard error == nil else {
                    print("Error performing object detection request: \(error!)")
                    return
                }
                
                guard let results = request.results as? [VNRecognizedObjectObservation] else {
                    return
                }
                
                var recognizedObjects: [RecognizedObject] = []
                
                for result in results {
                    let label = result.labels.first?.identifier
                    let confidence = result.confidence
                    let boundingBox = result.boundingBox
                    
                    let recognizedObject = RecognizedObject(label: label ?? "", confidence: confidence, boundingBox: boundingBox)
                    recognizedObjects.append(recognizedObject)
                }
                
                self.addRecognizedObjectsToFile(recognizedObjects, eyeTrackingData: eyeTrackingData, fileURL: fileURL)
            }
            
            let recognizedObjects: [RecognizedObject] = []
            
            try VNImageRequestHandler(cvPixelBuffer: frame, options: [:]).perform([objectDetectionRequest])
            
            // Return the recognized objects
            return recognizedObjects
        } catch {
            print("Error loading YOLOv3-Tiny model: \(error)")
            return []
        }
    }


    
    func loadFrame(at index: Int, using asset: AVAsset) async throws -> CVPixelBuffer? {
        guard let videoTrack = try await asset.loadTracks(withMediaType: .video).first else {
            return nil
        }
        
        let composition = AVMutableComposition()
        let videoCompositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        do {
            try await videoCompositionTrack?.insertTimeRange(CMTimeRange(start: CMTime.zero, duration: asset.load(.duration)), of: videoTrack, at: CMTime.zero)
            
            let assetReader = try AVAssetReader(asset: composition)
            let videoOutput = AVAssetReaderTrackOutput(track: videoCompositionTrack!, outputSettings: nil)
            
            assetReader.add(videoOutput)
            assetReader.startReading()
            
            guard let sampleBuffer = videoOutput.copyNextSampleBuffer() else {
                return nil
            }
            
            let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
            return pixelBuffer
        } catch {
            throw error
        }
    }


    
    func generateOutputURL() -> URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let filename = "ObjectData-\(dateFormatter.string(from: Date())).mov"
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        return outputURL
    }
    
    func addRecognizedObjectsToFile(_ objects: [RecognizedObject], eyeTrackingData: EyeTrackingData, fileURL: URL) {
        let timestamp = eyeTrackingData.timestamp
        let position = eyeTrackingData.position
        
        let text = objects.map { object in
            return """
            Timestamp: \(timestamp)
            Position: \(position)
            Label: \(object.label)
            Confidence: \(object.confidence)
            Bounding Box: \(object.boundingBox)
            ---
            """
        }.joined()
        
        if let data = text.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                } else {
                    print("Failed to open file handle for writing")
                }
            } else {
                FileManager.default.createFile(atPath: fileURL.path, contents: data, attributes: nil)
            }
        } else {
            print("Failed to convert text to data")
        }
    }
    // Retrieve the video track from the given AVAsset asynchronously
    func getVideoTrack(from asset: AVAsset) async throws -> AVAssetTrack? {
        let videoTracks = try await asset.loadTracks(withMediaType: .video)
        return videoTracks.first
    }
}

*/
