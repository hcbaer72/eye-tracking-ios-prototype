//
//  PupilDetection.swift
//  Eyes Tracking
//
//  Created by holly on 6/11/23.
//  Copyright © 2023 virakri. All rights reserved.
//

import Foundation
import UIKit

class Pupil {
    var irisFrame: UIImage?
    let threshold: Int
    var x: Int?
    var y: Int?
    
    init(eyeFrame: UIImage, threshold: Int) {
        self.irisFrame = nil
        self.threshold = threshold
        self.detectIris(eyeFrame: eyeFrame)
    }
    
    private static func imageProcessing(eyeFrame: UIImage, threshold: Int) -> UIImage? {
        let kernel = CIColorKernel(string:
            "kernel vec4 imageProcessing(__sample pixel, int threshold) {\n" +
            "    float luminance = dot(pixel.rgb, vec3(0.2126, 0.7152, 0.0722));\n" +
            "    return luminance > float(threshold) ? vec4(1.0, 1.0, 1.0, 1.0) : vec4(0.0, 0.0, 0.0, 1.0);\n" +
            "}"
        )
        
        guard let inputImage = CIImage(image: eyeFrame),
              let filter = kernel,
              let outputImage = filter.apply(extent: inputImage.extent, arguments: [inputImage, threshold])
        else {
            return nil
        }
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    private func detectIris(eyeFrame: UIImage) {
        self.irisFrame = self.imageProcessing(eyeFrame: eyeFrame, threshold: self.threshold)
        
        guard let irisFrame = self.irisFrame,
              let cvImageBuffer = irisFrame.toCVPixelBuffer(),
              let cvImage = CVImageBuffer.imageBufferToUIImage(cvImageBuffer)
        else {
            return
        }
        
        let cvMat = cvImage.convert(to: CV_8U)
        var contours: [Any] = []
        cvFindContours(cvMat, &contours, CV_RETR_TREE, CV_CHAIN_APPROX_NONE)
        
        contours = contours.sorted(by: { cvContourArea($0 as! CvSeq) < cvContourArea($1 as! CvSeq) })
        
        if let irisContour = contours[contours.count - 2] as? CvSeq {
            let moments = cvMoments(unsafeBitCast(irisContour, to: UnsafePointer<CvSeq>.self))
            let m00 = cvGetSpatialMoment(moments, 0, 0)
            let m10 = cvGetSpatialMoment(moments, 1, 0)
            let m01 = cvGetSpatialMoment(moments, 0, 1)
            
            if m00 != 0 {
                self.x = Int(m10 / m00)
                self.y = Int(m01 / m00)
            }
        }
    }
}
Please note that this Swift implementation uses OpenCV, which is a popular computer vision library. You will need to add the OpenCV framework to your Swift project and include the appropriate headers and imports. Additionally, the code assumes you have a bridging header to access OpenCV functions in Swift.






