//
//  gestureRecognition.swift
//  Eyes Tracking
//
//  Created by holly on 3/11/23.
//  Copyright © 2023 virakri. All rights reserved.
//

import Foundation
import UIKit
import WebKit

struct GestureData: Codable {
    let direction: String
    let startTime: Date
    let endTime: Date
}

class GestureRecognition: NSObject, UIGestureRecognizerDelegate  {
    public var webView: WKWebView?
    var gestureDataArray: [GestureData] = []
    
    init(webView: WKWebView) {
        guard let _ = webView.superview else {
                fatalError("WKWebView is not properly connected to GestureRecognition.")
            }
        self.webView = webView
        super.init()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        webView.addGestureRecognizer(tapRecognizer)
        
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeRecognizer.direction = .down
        webView.addGestureRecognizer(swipeRecognizer)

        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        webView.addGestureRecognizer(pinchRecognizer)

        let rotateRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(handleRotate(_:)))
        webView.addGestureRecognizer(rotateRecognizer)

        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        webView.addGestureRecognizer(panRecognizer)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Create a new GestureData object
        let gestureData = GestureData(direction: "tap", startTime: Date(), endTime: Date())
        
        // Record the gesture data
        self.recordGestureData(gestureData: gestureData)
        
        // Return true to allow the gesture recognizer to recognize the tap gesture
        return true
    }
    
    func recordGestureData(gestureData: GestureData) {
        do {
            let encodedData = try JSONEncoder().encode(gestureData)
            guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }
            let fileURL = dir.appendingPathComponent("gesture_data.txt")
            if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                // Append data to file
                fileHandle.seekToEndOfFile()
                fileHandle.write(encodedData)
                fileHandle.closeFile()
            } else {
                // File doesn't exist yet, create it and write data to it
                try encodedData.write(to: fileURL)
            }
            gestureDataArray.append(gestureData)
        } catch {
            print("Error recording gesture data: \(error.localizedDescription)")
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        // Get the location of the tap gesture
        let location = sender.location(in: webView)
        
        // Get the tapped element's html
        webView?.evaluateJavaScript("document.elementFromPoint(\(location.x), \(location.y)).outerHTML") { (result, error) in
            if let error = error {
                print("Error getting element from point: \(error.localizedDescription)")
                return
            }
            
            guard let elementHtml = result as? String else {
                print("Unable to get element html from result")
                return
            }
            
            // Do something with the tapped element's html
            print("Tapped element: \(elementHtml)")
        }
    }

    @objc func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        let swipeLocation = sender.location(in: webView)
        let swipeTime = Date()
        let gestureData = GestureData(direction: "down", startTime: swipeTime, endTime: swipeTime)
        recordGestureData(gestureData: gestureData)
    }

    @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
        let pinchTime = Date()
        let gestureData = GestureData(direction: "pinch", startTime: pinchTime, endTime: pinchTime)
        recordGestureData(gestureData: gestureData)
    }

    @objc func handleRotate(_ sender: UIRotationGestureRecognizer) {
        let rotationTime = Date()
        let gestureData = GestureData(direction: "rotate", startTime: rotationTime, endTime: rotationTime)
        recordGestureData(gestureData: gestureData)
    }

    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        let panLocation = sender.location(in: webView)
        let panTime = Date()
        let gestureData = GestureData(direction: "pan", startTime: panTime, endTime: panTime)
        recordGestureData(gestureData: gestureData)
        
    }
}
