//
//  UIKitView.swift
//  Eyes Tracking
//
//  Created by holly on 3/3/23.
//  Copyright © 2023 virakri. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit


class ViewController2: UIViewController {
    let contentView = UIHostingController(rootView: ContentView())
    
    override func viewDidLoad(){
        super.viewDidLoad()
        addChild(contentView)
        view.addSubview(contentView.view)
    }
}
