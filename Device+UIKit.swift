//
//  Device+UIKit.swift
//  Eyes Tracking
//

import UIKit

extension Device {
    var menuTitle: String {
        switch self {
        case .iPadPro12_9: return "12.9\" iPad Pro"
        case .iPadPro11: return "11\" iPad Pro"
        case .ipadPro10_5: return "10.5\" iPad Pro"
        case .iPadPro9_7: return "9.7\" iPad Pro"
        case .iPadMini7_9: return "iPad Mini"
        case .iPadAir10_5: return "10.5\" iPad Air"
        case .iPadAir9_7: return "9.7\" iPad Air"
        case .iPad10_9: return "10.9\" iPad"
        case .iPad10_2: return "10.2\" iPad"
        case .iPad9_7: return "9.7\" iPad"
        case .iPhoneXR: return "iPhone XR"
        case .iPhoneXS: return "iPhone XS"
        case .iPhoneXSMax: return "iPhone XS Max"
        case .iPhone11: return "iPhone 11"
        case .iPhone11Pro: return "iPhone 11 Pro"
        case .iPhone11ProMax: return "iPhone 11 Pro Max"
        case .iPhoneSE2: return "iPhone 11 SE2"
        case .iPhone12: return "iPhone 12"
        case .iPhone12mini: return "iPhone 12 mini"
        case .iPhone12Pro: return "iPhone 12 Pro"
        case .iPhone12ProMax: return "iPhone 12 Pro Max"
        case .iPhone13: return "iphone 13"
        case .iPhone13mini: return "iPhone 13 mini"
        case .iPhone13Pro: return "iPhone 13 Pro"
        case .iPhone13ProMax: return "iPhone 13 Pro Max"
        }
    }
    
    private func menuAction(_ closure: @escaping (Device)->()) -> UIMenuElement {
        UIAction(title: menuTitle) { _ in
            closure(self)
        }
    }
    
    static func menu(_ closure: @escaping (Device)->()) -> UIMenu {
        UIMenu(
            title: "Choose a Device",
            children: menuElements(closure)
        )
    }
    
    static private func menuElements(_ closure: @escaping (Device)->()) -> [UIMenuElement] {
        allCases.map { device in
            device.menuAction(closure)
        }
    }
}
