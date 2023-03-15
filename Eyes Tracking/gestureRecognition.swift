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

class GestureRecognition {
    private weak var webView: WKWebView?
    
    init(webView: WKWebView) {
        self.webView = webView
        
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
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        print("webview has own recognizer")
        return true
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
   // @objc func handleTap(_ sender: UITapGestureRecognizer) {
   //     let tapLocation = sender.location(in: myView)
   //     let tapTime = Date()
   //     let tapData = ["type": "tap", "x": tapLocation.x, "y": tapLocation.y, "timestamp": tapTime] as [String : Any]
//    recordGestureData(gestureData: tapData)
   // }

    @objc func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        let swipeLocation = sender.location(in: webView)
        let swipeTime = Date()
        let swipeData = ["type": "swipe", "direction": "down", "x": swipeLocation.x, "y": swipeLocation.y, "timestamp": swipeTime] as [String : Any]
        recordGestureData(gestureData: swipeData)
    }

    @objc func handlePinch(_ sender: UIPinchGestureRecognizer) {
        let pinchScale = sender.scale
        let pinchTime = Date()
        let pinchData = ["type": "pinch", "scale": pinchScale, "timestamp": pinchTime] as [String : Any]
        recordGestureData(gestureData: pinchData)
    }

    @objc func handleRotate(_ sender: UIRotationGestureRecognizer) {
        let rotationAngle = sender.rotation
        let rotationTime = Date()
        let rotationData = ["type": "rotate", "angle": rotationAngle, "timestamp": rotationTime] as [String : Any]
        recordGestureData(gestureData: rotationData)
    }

    @objc func handlePan(_ sender: UIPanGestureRecognizer) {
        let panLocation = sender.location(in: webView)
        let panTime = Date()
        let panData = ["type": "pan", "x": panLocation.x, "y": panLocation.y, "timestamp": panTime] as [String : Any]
        recordGestureData(gestureData: panData)
    }

    func recordGestureData(gestureData: [String: Any]) {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        let fileURL = dir.appendingPathComponent("gesture_data.txt")
        do {
            let data = try JSONSerialization.data(withJSONObject: gestureData, options: .prettyPrinted)
            try data.write(to: fileURL)
        } catch {
           print("Error writing gesture data to file: \(error.localizedDescription)")
        }
    }
}
