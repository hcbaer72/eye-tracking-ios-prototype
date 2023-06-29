//
//  ML Extension.swift
//  Eyes Tracking
//
//  Created by holly on 6/29/23.
//  Copyright © 2023 virakri. All rights reserved.
//

import Foundation
import Vision
import AVFoundation


class EyeTrackingCameraController: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureSession: AVCaptureSession?

    override init() {
        super.init()

        self.captureSession = AVCaptureSession()

        guard let captureSession = self.captureSession else { return }
        captureSession.sessionPreset = .medium

        guard let captureDevice = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(videoOutput)

        captureSession.startRunning()
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let faceLandmarksRequest = VNDetectFaceLandmarksRequest { request, error in
            if let error = error {
                print("Error in face landmarks request: \(error)")
                return
            }

            guard let results = request.results as? [VNFaceObservation] else {
                print("No face landmarks detected.")
                return
            }

            for faceObservation in results {
                let leftEye = faceObservation.landmarks?.leftEye
                let rightEye = faceObservation.landmarks?.rightEye

                if let leftPupil = leftEye?.pupil {
                    let leftPupilPoint = CGPoint(x: leftPupil.x * faceObservation.boundingBox.width + faceObservation.boundingBox.origin.x,
                                                 y: leftPupil.y * faceObservation.boundingBox.height + faceObservation.boundingBox.origin.y)
                    print("Left Pupil - X: \(leftPupilPoint.x), Y: \(leftPupilPoint.y)")
                }

                if let rightPupil = rightEye?.pupil {
                    let rightPupilPoint = CGPoint(x: rightPupil.x * faceObservation.boundingBox.width + faceObservation.boundingBox.origin.x,
                                                  y: rightPupil.y * faceObservation.boundingBox.height + faceObservation.boundingBox.origin.y)
                    print("Right Pupil - X: \(rightPupilPoint.x), Y: \(rightPupilPoint.y)")
                }
            }
        }

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])

        do {
            try imageRequestHandler.perform([faceLandmarksRequest])
        } catch {
            print("Error performing face landmarks request: \(error)")
        }
    }
}
