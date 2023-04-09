//
//  webviewGestureRecognition.swift
//  Eyes Tracking
//
//  Created by holly on 3/15/23.
//  Copyright © 2023 virakri. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class MyViewController3: UIViewController {
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
    
    webView.addGestureRecognizer(tapRecognizer)
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: webView)
        let tagName = webView.stringByEvaluatingJavaScript(from: "document.elementFromPoint(\(location.x), \(location.y)).tagName") ?? ""
        let gestureData = ["gesture": "tap", "tag": tagName]
        recordGestureData(gestureData: gestureData)
        
        }
    }
