//
//  CalibrationViewController.swift
//  Eyes Tracking
//
//  Created by Kristen Lineback on 4/5/23.
//  Copyright © 2023 virakri. All rights reserved.
//

// TODO: Track and record the amount of frames for each dot
//import Foundation
//import UIKit
//import AVFoundation
//import CodableCSV
//
//class CalibrationViewController: UIViewController {
//
//    @IBOutlet var faceVisibilityWarningLabel: UILabel!
//
//
//    private let captureSession = AVCaptureSession()
//    private let videoDataOutput = AVCaptureVideoDataOutput()
//
//    private var calibrationInProgress: Bool = false
//    private var dotLayers: [CAShapeLayer] = []
//    private var currentDotPredictions: [(Double, Double)] = []
//    private var rawGazeEst: (Double, Double) = (0,0)
//    private var isFaceVisible: Bool = false
//    private var currAcceptableCalibrationFramesCount: Int = 0
//    private var timers: [Timer] = []
//
//    private var dotLocationIndex: Int = 0
//    private let dotLocations: [CGPoint] = [CGPoint(x: 20, y: 20), CGPoint(x: 814, y: 20), CGPoint(x: 120, y: 350), CGPoint(x: 400, y: 400), CGPoint(x: 680, y: 450), CGPoint(x: 120, y: 700), CGPoint(x: 400, y: 750), CGPoint(x: 680, y: 800), CGPoint(x: 20, y: 1174), CGPoint(x: 814, y: 1174)]
//    private let timeDelayBetweenDots: Double = 2.0
//    private var xScaling = 3.0// Scaling factor for iTracker
//    private var yScaling = 2.0
//    private var xTranslation = 1.5// Translations in cm, converted to screen points in utility function
//    private var yTranslation = 9.0
//
//    // Data stores
//    private var averagedGazePredictions: [CGPoint] = []// Average gaze prediction in screen coords, one for each calibration point shown.
//    private var pointDistances: [CGFloat] = []// Distances between the averagedGazePrediction point and each relevant calibration point in CM.
//    private var cornerGazePredictions: [String] = []
//    private var dotError: Double = 0.0
//    private var xRange: Double = 0.0
//    private var yRange: Double = 0.0
//    private var xRangeGroundTruth: Double = 0.0
//    private var yRangeGroundTruth: Double = 0.0
//    private var meanXDeviation: Double = 0.0
//    private var meanYDeviation: Double = 0.0
//    private var allGazePredictions: [(Int, Double, Double, Double)] = []
//
//}
