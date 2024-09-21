import SwiftUI
import Cocoa

enum FanSpeed {
    case off
    case low
    case medium
    case high
    
    var swiftUIColor: Color {
        switch self {
        case .off: return Color(white: 0.7)  // Light gray
        case .low: return Color(white: 0.5)  // Medium gray
        case .medium: return Color(white: 0.3)  // Dark gray
        case .high: return Color.black
        }
    }
    
    var nsColor: NSColor {
        switch self {
        case .off: return NSColor(white: 0.7, alpha: 1.0)  // Light gray
        case .low: return NSColor(white: 0.5, alpha: 1.0)  // Medium gray
        case .medium: return NSColor(white: 0.3, alpha: 1.0)  // Dark gray
        case .high: return NSColor.black
        }
    }
}
