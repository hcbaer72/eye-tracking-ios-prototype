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




extension ViewController {
    
    //  convenience init(videoURL: URL, eyeTrackingData: [EyeTrackingData], device: Device, assetReaderOutputs: [AVAssetReaderOutput]) {
    //      self.init(videoURL: videoURL, eyeTrackingData: eyeTrackingData, device: device, assetReaderOutputs: assetReaderOutputs)
    // Other initialization code
    //  }
    
    
    func processEyeTrackingDataWithImageAnalysis(completion: @escaping () -> Void) async {
        // Ensure that the eye tracking data is available
        guard !eyeTrackingData.isEmpty else {
            print("Eye tracking data is empty.")
            completion()
            return
        }
        
        // Load the screen recording video
        guard let videoURL = self.videoURL else {
            print("VideoURL is nil. Make sure it is set before calling processEyeTrackingDataWithImageAnalysis.")
            completion()
            return
        }
        
        let asset = AVAsset(url: videoURL)
        
        do {
            // Get the video track from the asset
            guard let videoTrack = try await getVideoTrack(from: asset) else {
                print("Failed to retrieve the video track from the asset.")
                completion()
                return
            }
            
            do {
                let assetReader = try AVAssetReader(asset: asset)
                
                // Add video output to the asset reader
                let videoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: nil)
                assetReader.add(videoOutput)
                
                // Start the asset reader
                assetReader.startReading()
                
                // Process each eye tracking data point
                for eyeTrackingPoint in eyeTrackingData {
                    do {
                        let videoFrameIndex = try await mapEyeTrackingPointToVideoFrame(eyeTrackingPoint: eyeTrackingPoint, videoTrack: videoTrack)
                        
                        // Load the frame from the video
                        guard let frame = loadFrame(at: videoFrameIndex, using: assetReader.outputs, assetReader: assetReader) else {
                            continue
                        }
                        
                        // Perform image analysis using Vision
                        do {
                            let recognizedObjects = try await performImageAnalysis(on: frame, eyeTrackingPoint: eyeTrackingPoint)
                            
                            // Perform further analysis or associate the recognized objects with the eye tracking data
                            // ...
                            
                            // Example: Print the recognized objects
                            for object in recognizedObjects {
                                print("Recognized Object Label: \(object.label)")
                                print("Confidence: \(object.confidence)")
                                print("Bounding Box: \(object.boundingBox)")
                                print("---")
                            }
                            
                        } catch {
                            print("Error performing image analysis for eye tracking data point: \(error)")
                        }
                    } catch {
                        print("Error mapping eye tracking point to video frame: \(error)")
                    }
                }
                
                // Finish reading the asset
                assetReader.cancelReading()
                
                completion()
            } catch {
                print("Error creating or reading the asset: \(error)")
                completion()
            }
            
            func performImageAnalysis(on frame: CVPixelBuffer, eyeTrackingPoint: EyeTrackingData) async throws -> [RecognizedObject] {
                var recognizedObjects: [RecognizedObject] = []
                
                // Perform feature extraction using Vision
                let saliencyImage = await performFeatureExtraction(on: frame)
                
                // Perform object recognition using Vision
                recognizedObjects = try await performObjectRecognition(on: frame)
                
                // Perform further analysis or associate the recognized objects with the eye tracking data
                // ...
                
                return recognizedObjects
            }
            func performFeatureExtraction(on frame: CVPixelBuffer) async -> CGImage? {
                  let request = VNGenerateAttentionBasedSaliencyImageRequest { request, error in
                      guard error == nil else {
                          print("Error performing feature extraction request: \(error!)")
                          return
                      }
                      
                      guard let result = request.results?.first as? VNPixelBufferObservation else {
                          return
                      }
                      
                      let saliencyImage = result.pixelBuffer.toImage()
                      
                      // Process the feature extraction results
                      // ...
                  }
                  
                  let requestHandler = VNImageRequestHandler(cvPixelBuffer: frame, options: [:])
                  
                  do {
                      try await requestHandler.perform([request])
                      return saliencyImage
                  } catch {
                      print("Error performing feature extraction request: \(error)")
                      return nil
                  }
              }
              
            
            func mapEyeTrackingPointToVideoFrame(eyeTrackingPoint: EyeTrackingData, videoTrack: AVAssetTrack) async throws -> Int {
                let eyeTrackingTimestamp = eyeTrackingPoint.timestamp
                let frameRate = try await getFrameRate(from: videoTrack)
                
                let frameRateInSeconds = TimeInterval(frameRate)
                let videoFrameIndex = Int(eyeTrackingTimestamp * frameRateInSeconds)
                return videoFrameIndex
            }
            
            
            // Function to write the identified objects and features along with fixation analysis to a text file
            func writeIdentifiedObjectsWithFixationAnalysis(objects: [RecognizedObject], fixations: [FixationData]) {
                // Generate the fixation analysis string
                var analysisString = "Fixation Duration Analysis:\n\n"
                
                for (index, fixation) in fixations.enumerated() {
                    analysisString += "Fixation \(index + 1):\n"
                    analysisString += "Start Time: \(fixation.startTime)\n"
                    analysisString += "Duration: \(fixation.duration) seconds\n"
                    analysisString += "Center: (\(fixation.center.x), \(fixation.center.y))\n\n"
                }
                
                // Convert the fixations and recognized objects data to string format
                var fileContent = ""
                
                for (index, fixation) in fixations.enumerated() {
                    fileContent += "Fixation \(index + 1):\n"
                    fileContent += "Timestamp: \(fixation.startTime)\n"
                    fileContent += "Duration: \(fixation.duration)\n"
                    fileContent += "Center: (\(fixation.center.x), \(fixation.center.y))\n"
                    
                    let recognizedObjects = fixation.recognizedObjects
                    
                    if !recognizedObjects.isEmpty {
                        fileContent += "Recognized Objects:\n"
                        
                        for object in recognizedObjects {
                            fileContent += "Label: \(object.label)\n"
                            fileContent += "Confidence: \(object.confidence)\n"
                            fileContent += "Bounding Box: \(object.boundingBox)\n"
                            fileContent += "\n"
                        }
                    }
                    
                    fileContent += "\n"
                }
                
                // Combine the fixation analysis and recognized objects data
                let finalContent = analysisString + "\n\n" + fileContent
                
                // Write the combined content to the text file
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
                let filename = "FixationAnalysis-\(dateFormatter.string(from: Date())).txt"
                let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
                
                do {
                    try finalContent.write(to: fileURL, atomically: true, encoding: .utf8)
                    print("Fixation analysis and identified objects saved to file: \(filename)")
                } catch {
                    print("Error writing to file: \(error)")
                }
            }
            func performObjectRecognition(on frame: CVPixelBuffer, modelURL: URL) async throws -> [RecognizedObject] {
                let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
                
                let objectRecognitionRequest = VNCoreMLRequest(model: visionModel) { request, error in
                    guard error == nil else {
                        print("Error performing object recognition request: \(error!)")
                        return
                    }
                    
                    guard let results = request.results as? [VNRecognizedObjectObservation] else {
                        return
                    }
                    
                    // Process the object recognition results
                    var recognizedObjects: [RecognizedObject] = []
                    
                    for result in results {
                        // Extract label, confidence, and bounding box information from the result
                        
                        // Example: Get the label of the recognized object
                        let label = result.labels.first?.identifier
                        
                        // Example: Get the confidence of the recognized object
                        let confidence = result.confidence
                        
                        // Example: Get the bounding box of the recognized object
                        let boundingBox = result.boundingBox
                        
                        // Create a RecognizedObject instance with label, confidence, and bounding box
                        let recognizedObject = RecognizedObject(label: label ?? "", confidence: confidence, boundingBox: boundingBox)
                        
                        recognizedObjects.append(recognizedObject)
                    }
                    
                    // Perform further analysis or filtering of recognized objects
                    // ...
                    
                    // Return the recognized objects
                    return recognizedObjects
                }
                
                // Create a Vision request handler for the current frame
                let requestHandler = VNImageRequestHandler(cvPixelBuffer: frame, options: [:])
                
                // Perform the object recognition request
                do {
                    try await requestHandler.perform([objectRecognitionRequest])
                    return objectRecognitionRequest.results as? [RecognizedObject] ?? []
                } catch {
                    print("Error performing object recognition request: \(error)")
                    throw error
                }
            }

            // Load a specific frame from the screen recording video
            func loadFrame(at index: Int, using assetReaderOutputs: [AVAssetReaderOutput], assetReader: AVAssetReader) -> CVPixelBuffer? {
                // Get the video output from the asset reader's outputs
                guard let videoOutput = assetReaderOutputs.first as? AVAssetReaderVideoCompositionOutput else {
                    return nil
                }
                
                // Ensure the output has been initialized
                guard assetReader.status == .reading else {
                    return nil
                }
                
                // Get the frame at the specified index
                guard let sampleBuffer = videoOutput.copyNextSampleBuffer() else {
                    return nil
                }
                
                let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
                return pixelBuffer
            }
            
            // Retrieve the frame rate from the given AVAssetTrack asynchronously
            func getFrameRate(from videoTrack: AVAssetTrack) async throws -> Float {
                return try await videoTrack.load(.nominalFrameRate)
            }
            // Retrieve the video track from the given AVAsset asynchronously
            func getVideoTrack(from asset: AVAsset) async throws -> AVAssetTrack? {
                let videoTracks = try await asset.loadTracks(withMediaType: .video)
                return videoTracks.first
            }
            func convertPixelBufferToUIImage(pixelBuffer: CVPixelBuffer) -> UIImage? {
                let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
                let context = CIContext()
                
                guard let cgImage = context.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))) else {
                    return nil
                }
                
                return UIImage(cgImage: cgImage)
            }

            }
            
        }
        
    }
}
