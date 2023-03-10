//
//  Device.swift
//  Eyes Tracking
//

import Foundation

enum Device: CaseIterable {
    case iPadPro12_9
    case iPadPro11
    case ipadPro10_5
    case iPadPro9_7
    case iPadMini7_9
    case iPadAir10_5
    case iPadAir9_7
    case iPad10_9
    case iPad10_2
    case iPad9_7
    case iPhoneXR
    case iPhoneXS
    case iPhoneXSMax
    case iPhone11
    case iPhone11Pro
    case iPhone11ProMax
    case iPhoneSE2
    case iPhone12
    case iPhone12mini
    case iPhone12Pro
    case iPhone12ProMax
    case iPhone13
    case iPhone13mini
    case iPhone13Pro
    case iPhone13ProMax
    
    var heightInPixels: Float {
        heightInPoints * pixelsPerPoint
    }
    var widthInPixels: Float {
        widthInPoints * pixelsPerPoint
    }
    var heightInPoints: Float {
        switch self {
        case .iPadPro12_9: return 1366
        case .iPadPro11: return 1194
        case .ipadPro10_5: return 1194
        case .iPadPro9_7: return 1024
        case .iPadMini7_9: return 1024
        case .iPadAir10_5: return 1112
        case .iPadAir9_7: return 1024
        case .iPad10_9: return 1180
        case .iPad10_2: return 1080
        case .iPad9_7: return 1024
        case .iPhoneXR: return 896
        case .iPhoneXS: return 812
        case .iPhoneXSMax: return 896
        case .iPhone11: return 896
        case .iPhone11Pro: return 812
        case .iPhone11ProMax: return 896
        case .iPhoneSE2: return 667
        case .iPhone12: return 844
        case .iPhone12mini: return 780
        case .iPhone12Pro: return 844
        case .iPhone12ProMax: return 926
        case .iPhone13: return 844
        case .iPhone13mini: return 780
        case .iPhone13Pro: return 844
        case .iPhone13ProMax: return 926
        
        }
    }
    var widthInPoints: Float {
        switch self {
        case .iPadPro12_9: return 1024
        case .iPadPro11: return 834
        case .ipadPro10_5: return 834
        case .iPadPro9_7: return 768
        case .iPadMini7_9: return 768
        case .iPadAir10_5: return 834
        case .iPadAir9_7: return 768
        case .iPad10_9: return 820
        case .iPad10_2: return 810
        case .iPad9_7: return 768
        case .iPhoneXR: return 414
        case .iPhoneXS: return 375
        case .iPhoneXSMax: return 414
        case .iPhone11: return 414
        case .iPhone11Pro: return 375
        case .iPhone11ProMax: return 414
        case .iPhoneSE2: return 375
        case .iPhone12: return 390
        case .iPhone12mini: return 360
        case .iPhone12Pro: return 390
        case .iPhone12ProMax: return 428
        case .iPhone13: return 390
        case .iPhone13mini: return 360
        case .iPhone13Pro: return 390
        case .iPhone13ProMax: return 428
        }
    }
    var pixelsPerPoint: Float {
    //2 pixels per point for ipad
    //3 pixels per point for iphone
        switch self {
        case .iPadPro12_9: return 2
        case .iPadPro11: return 2
        case .ipadPro10_5: return 2
        case .iPadPro9_7: return 2
        case .iPadMini7_9: return 2
        case .iPadAir10_5: return 2
        case .iPadAir9_7: return 2
        case .iPad10_9: return 2
        case .iPad10_2: return 2
        case .iPad9_7: return 2
        case .iPhoneXR: return 2
        case .iPhoneXS: return 3
        case .iPhoneXSMax: return 3
        case .iPhone11: return 2
        case .iPhone11Pro: return 3
        case .iPhone11ProMax: return 3
        case .iPhoneSE2: return 2
        case .iPhone12: return 3
        case .iPhone12mini: return 2
        case .iPhone12Pro: return 3
        case .iPhone12ProMax: return 3
        case .iPhone13: return 3
        case .iPhone13mini: return 3
        case .iPhone13Pro: return 3
        case .iPhone13ProMax: return 3
        }
    }
    var diagonalSizeInInches: Float {
        switch self {
        case .iPadPro12_9: return 12.9
        case .iPadPro11: return 11
        case .ipadPro10_5: return 10.5
        case .iPadPro9_7: return 9.7
        case .iPadMini7_9: return 7.9
        case .iPadAir10_5: return 10.5
        case .iPadAir9_7: return 9.7
        case .iPad10_9: return 10.9
        case .iPad10_2: return 10.2
        case .iPad9_7: return 9.7
        case .iPhoneXR: return 6.1
        case .iPhoneXS: return 5.8
        case .iPhoneXSMax: return 6.5
        case .iPhone11: return 6.1
        case .iPhone11Pro: return 5.8
        case .iPhone11ProMax: return 6.5
        case .iPhoneSE2: return 4.7
        case .iPhone12: return 6.1
        case .iPhone12mini: return 5.4
        case .iPhone12Pro: return 6.1
        case .iPhone12ProMax: return 6.7
        case .iPhone13: return 6.1
        case .iPhone13mini: return 5.4
        case .iPhone13Pro: return 6.1
        case .iPhone13ProMax: return 6.7
        }
    }
    var diagonalSizeInMilliMeters: Float {
        switch self {
        case .iPadPro12_9: return Float(12.9 * 25.4)
        case .iPadPro11: return Float(11 * 25.4)
        case .ipadPro10_5: return Float(10.5 * 25.4)
        case .iPadPro9_7: return Float(9.7 * 25.4)
        case .iPadMini7_9: return Float(7.9 * 25.4)
        case .iPadAir10_5: return Float(10.5 * 25.4)
        case .iPadAir9_7: return Float(9.7 * 25.4)
        case .iPad10_9: return Float(10.9 * 25.4)
        case .iPad10_2: return Float(10.2 * 25.4)
        case .iPad9_7: return Float(9.7 * 25.4)
        case .iPhoneXR: return Float(6.1 * 25.4)
        case .iPhoneXS: return Float(5.8 * 25.4)
        case .iPhoneXSMax: return Float(6.5 * 25.4)
        case .iPhone11: return Float(6.1 * 25.4)
        case .iPhone11Pro: return Float(5.8 * 25.4)
        case .iPhone11ProMax: return Float(6.5 * 25.4)
        case .iPhoneSE2: return Float(4.7 * 25.4)
        case .iPhone12: return Float(6.1 * 25.4)
        case .iPhone12mini: return Float(5.4 * 25.4)
        case .iPhone12Pro: return Float(6.1 * 25.4)
        case .iPhone12ProMax: return Float(6.7 * 25.4)
        case .iPhone13: return Float(6.1 * 25.4)
        case .iPhone13mini: return Float(5.4 * 25.4)
        case .iPhone13Pro: return Float(6.1 * 25.4)
        case .iPhone13ProMax: return Float(6.7 * 25.4)
        }
    }
//    var pointSizeInMeters: Double {
//        let diagonalSizeInMillimeters = diagonalSizeInInches * 25.4
//        let diagonalSizeInPoints =  widthInPoints^2 * heightInPoints^2
//        fatalError()
//    }
    
//    var cDevice: HBDevice {
//        return HBDevice(widthInPixels: Int32(widthInPoints * pixelsPerPoint),
//                        heightInPixels: Int32(heightInPoints * pixelsPerPoint),
//                        widthInPoints: Int32(widthInPoints),
//                        heightInPoints: Int32(heightInPoints),
//                        pixelsPerPoint: Int32(pixelsPerPoint)
//        )
//    }
    var meterHeight: Float {
        switch self {
        case .iPad10_2: return 0.24
        case .iPadPro12_9: return 0.28
        case .iPadPro11: return 0.24
        case .ipadPro10_5: return 0.19
        case .iPadPro9_7: return 0.17
        case .iPadMini7_9: return 0.14
        case .iPadAir10_5: return 0.19
        case .iPadAir9_7: return 0.17
        case .iPad10_9: return 0.245
        case .iPad9_7: return 0.17
        case .iPhoneXR: return 0.0621
        case .iPhoneXS: return 0.0549
        case .iPhoneXSMax: return 0.0621
        case .iPhone11: return 0.0549
        case .iPhone11Pro: return 0.0621
        case .iPhone11ProMax: return 0.0549
        case .iPhoneSE2: return 0.0532
        case .iPhone12: return 0.0574
        case .iPhone12mini: return 0.0500
        case .iPhone12Pro: return 0.0574
        case .iPhone12ProMax: return 0.0630
        case .iPhone13: return 0.0574
        case .iPhone13mini: return 0.0500
        case .iPhone13Pro: return 0.0574
        case .iPhone13ProMax: return 0.0630
        }
    }
    var meterWidth: Float {
        switch self {
        case .iPad10_2: return 0.187
        case .iPadPro12_9: return 0.21
        case .iPadPro11: return 0.18
        case .ipadPro10_5: return 0.14
        case .iPadPro9_7: return 0.13
        case .iPadMini7_9: return 0.10
        case .iPadAir10_5: return 0.14
        case .iPadAir9_7: return 0.13
        case .iPad10_9: return 0.176
        case .iPad9_7: return 0.13
        case .iPhoneXR: return 0.1341
        case .iPhoneXS: return 0.1213
        case .iPhoneXSMax: return 0.1341
        case .iPhone11: return 0.1341
        case .iPhone11Pro: return 0.1213
        case .iPhone11ProMax: return 0.1341
        case .iPhoneSE2: return 0.0951
        case .iPhone12: return 0.1241
        case .iPhone12mini: return 0.1085
        case .iPhone12Pro: return 0.1241
        case .iPhone12ProMax: return 0.1366
        case .iPhone13: return 0.1241
        case .iPhone13mini: return 0.1085
        case .iPhone13Pro: return 0.1241
        case .iPhone13ProMax: return 0.1366
        }
    }
}

