//
//  Device.swift
//  Eyes Tracking
//

import Foundation


//heightInPixels
//widthInPixels
//heightInPoints
//widthInPoints
//pixelsPerPoint
//diagonalSizeInInches
//diagonalSizeInMilliMeters
//pointSizeInMeters
//meterHeight
//meterWidth



enum Device: String, CaseIterable {
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
    
    public var heightInPixels: Double {
        heightInPoints * pixelsPerPoint
    }
    public var widthInPixels: Double {
        widthInPoints * pixelsPerPoint
    }
    public var heightInPoints: Double {
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
    
    var heightCompensation: Double {
        let screenHeight = self.phoneScreenSize.height
        let screenPointSizeHeight = self.phoneScreenPointSize.height
        let normalizedScreenY = 1 - Double(screenHeight) / Double(screenPointSizeHeight)
        return normalizedScreenY * screenPointSizeHeight / 2
    }
    
    var widthInPoints: Double {
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
    var pixelsPerPoint: Double {
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
    var diagonalSizeInInches: Double {
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
    var diagonalSizeInMilliMeters: Double {
        switch self {
        case .iPadPro12_9: return Double(12.9 * 25.4)
        case .iPadPro11: return Double(11 * 25.4)
        case .ipadPro10_5: return Double(10.5 * 25.4)
        case .iPadPro9_7: return Double(9.7 * 25.4)
        case .iPadMini7_9: return Double(7.9 * 25.4)
        case .iPadAir10_5: return Double(10.5 * 25.4)
        case .iPadAir9_7: return Double(9.7 * 25.4)
        case .iPad10_9: return Double(10.9 * 25.4)
        case .iPad10_2: return Double(10.2 * 25.4)
        case .iPad9_7: return Double(9.7 * 25.4)
        case .iPhoneXR: return Double(6.1 * 25.4)
        case .iPhoneXS: return Double(5.8 * 25.4)
        case .iPhoneXSMax: return Double(6.5 * 25.4)
        case .iPhone11: return Double(6.1 * 25.4)
        case .iPhone11Pro: return Double(5.8 * 25.4)
        case .iPhone11ProMax: return Double(6.5 * 25.4)
        case .iPhoneSE2: return Double(4.7 * 25.4)
        case .iPhone12: return Double(6.1 * 25.4)
        case .iPhone12mini: return Double(5.4 * 25.4)
        case .iPhone12Pro: return Double(6.1 * 25.4)
        case .iPhone12ProMax: return Double(6.7 * 25.4)
        case .iPhone13: return Double(6.1 * 25.4)
        case .iPhone13mini: return Double(5.4 * 25.4)
        case .iPhone13Pro: return Double(6.1 * 25.4)
        case .iPhone13ProMax: return Double(6.7 * 25.4)
        }
    }
    
    var pointSizeInMeters: Double {
        let diagonalSizeInMillimeters = diagonalSizeInInches * 25.4
        let diagonalSizeInPoints =  pow(widthInPoints, 2) * pow(heightInPoints, 2)
        fatalError()
    }
    
    var phoneScreenSize: CGSize {
                return CGSize(width: meterWidth, height: meterHeight)
            }
            
    var phoneScreenPointSize: CGSize {
                return CGSize(width: widthInPoints, height: heightInPoints)
            }

   public var meterHeight: Double {
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
    public var meterWidth: Double {
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


