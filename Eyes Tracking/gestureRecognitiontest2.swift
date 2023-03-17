//
//  gestureRecognitiontest2.swift
//  Eyes Tracking
//
//  Created by holly on 3/15/23.
//  Copyright © 2023 virakri. All rights reserved.
//

import UIKit
import WebKit

class GestureRecognizer {
    
    var webView: WKWebView
    
    init(webView: WKWebView) {
        self.webView = webView
        
        // Add gesture recognizer to the web view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        webView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        // Get the location of the tap gesture
        let location = sender.location(in: webView)
        
        // Get the tapped element's html
        webView.evaluateJavaScript("document.elementFromPoint(\(location.x), \(location.y)).outerHTML") { (result, error) in
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
}
