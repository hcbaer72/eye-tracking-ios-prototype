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
import GoogleSignIn
import GoogleSignInSwift
import YoutubeKit
import YoutubePlayerView


struct GestureData: Codable {
    let direction: String
    let startTime: Date
    let endTime: Date
    let element: String?
}

class GestureRecognition: NSObject, UIGestureRecognizerDelegate  {
    public var webView: WKWebView?
    var gestureDataArray: [GestureData] = []
    var filePath: URL?
    
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
        let gestureData = GestureData(direction: "tap", startTime: Date(), endTime: Date(), element: "test")
        
        // Record the gesture data
        self.recordGestureData(gestureData: gestureData)
        
        // Return true to allow the gesture recognizer to recognize the tap gesture
        return true
    }
    
    func recordGestureData(gestureData: GestureData) {
        do {
            let encodedData = try JSONEncoder().encode(gestureData)
            let decodedData = try JSONDecoder().decode(GestureData.self, from: encodedData)
            gestureDataArray.append(decodedData)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
            let dateString = dateFormatter.string(from: Date())
            guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                return
            }
            let fileName = "gesture_data_\(dateString).txt"
            let fileURL = dir.appendingPathComponent(fileName)
            filePath = fileURL
            
            
            if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
                defer {
                    fileHandle.closeFile()
                }
                fileHandle.seekToEndOfFile()
                fileHandle.write("\n".data(using: .utf8)!)
                fileHandle.write(encodedData)
            } else {
                try encodedData.write(to: fileURL)
            }
        } catch {
            print("Error recording gesture data: \(error.localizedDescription)")
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        print("tapped")
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
            
            // Append the gesture data to the file
            let GestureData = "\(location.x),\(location.y),\(elementHtml)\n"
            
            guard let filePath = self.filePath else {
                print("File path is nil")
                return
            }
            
            if let fileHandle = try? FileHandle(forWritingTo: filePath), let data = GestureData.data(using: .utf8) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            } else {
                do {
                    try GestureData.write(to: filePath, atomically: true, encoding: .utf8)
                } catch {
                    print("Error writing gesture data to file: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc func handleTapping(_ sender: UITapGestureRecognizer) {
        print("tapped")
        // Get the location of the tap gesture
        let tapLocation = sender.location(in: webView)
        
        // Get the tapped element's html
        webView?.evaluateJavaScript("document.elementFromPoint(\(tapLocation.x), \(tapLocation.y)).outerHTML") { (result, error) in
            if let error = error {
                print("Error getting element from point: \(error.localizedDescription)")
                return
            }
            
            guard let elementHtml = result as? String else {
                print("Unable to get element html from result")
                return
            }
            
            let tapTime = Date()
            let gestureData = GestureData(direction: "tap", startTime: tapTime, endTime: tapTime, element: elementHtml)
            self.recordGestureData(gestureData: gestureData)
        }
    }
    
    @objc func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        print("swiped")
        let swipeLocation = sender.location(in: webView)
        let swipeTime = Date()
        let gestureData = GestureData(direction: "down", startTime: swipeTime, endTime: swipeTime, element: elementAtPoint(swipeLocation))
        recordGestureData(gestureData: gestureData)
    }
    
    @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
        print("pinched")
        let pinchTime = Date()
        let gestureData = GestureData(direction: "pinch", startTime: pinchTime, endTime: pinchTime, element: elementAtPoint(sender.location(in: webView)))
        recordGestureData(gestureData: gestureData)
    }
    
    @objc func handleRotate(_ sender: UIRotationGestureRecognizer) {
        print("rotated")
        let rotationTime = Date()
        let gestureData = GestureData(direction: "rotate", startTime: rotationTime, endTime: rotationTime, element: elementAtPoint(sender.location(in: webView)))
        recordGestureData(gestureData: gestureData)
    }
    
    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        print("panned")
        let panLocation = sender.location(in: webView)
        let panTime = Date()
        let gestureData = GestureData(direction: "pan", startTime: panTime, endTime: panTime, element: elementAtPoint(panLocation))
        recordGestureData(gestureData: gestureData)
    }
    
    func elementAtPoint(_ point: CGPoint) -> String {
        let hitTestResult = webView?.hitTest(point, with: nil)
        let viewClassName = String(describing: type(of: webView))

        if let tagName = hitTestResult?.tag,
            let idName = hitTestResult?.accessibilityIdentifier {
            return "<\(tagName) class=\"\(viewClassName)\" id=\"\(idName)\">"
        } else {
            return "unknown element"
        }
    }
}
