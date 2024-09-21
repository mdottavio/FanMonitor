import Cocoa
import SwiftUI

class FanIconView: NSView {
    private var hostingView: NSHostingView<FanIconSwiftUI>?
    
    func updateIcon(for speed: FanSpeed) {
        if let hostingView = hostingView {
            hostingView.rootView = FanIconSwiftUI(speed: speed, size: bounds.width)
        } else {
            let fanIcon = FanIconSwiftUI(speed: speed, size: bounds.width)
            hostingView = NSHostingView(rootView: fanIcon)
            hostingView!.frame = bounds
            hostingView!.autoresizingMask = [.width, .height]
            addSubview(hostingView!)
        }
    }
}

struct FanIconSwiftUI: View {
    let speed: FanSpeed
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Fan blades
            ForEach(0..<3) { i in
                FanBlade()
                    .fill(speed.swiftUIColor)
                    .frame(width: size * 0.4, height: size * 0.15)
                    .offset(x: size * 0.15)
                    .rotationEffect(.degrees(Double(i) * 120))
            }
            
            // Center circle
            Circle()
                .fill(speed.swiftUIColor)
                .frame(width: size * 0.2, height: size * 0.2)
            
            // Motion lines
            ForEach(0..<motionLineCount, id: \.self) { i in
                MotionLine()
                    .stroke(speed.swiftUIColor, lineWidth: 1)
                    .frame(width: size * 0.1, height: size * 0.5)
                    .offset(x: size * 0.45)
                    .rotationEffect(.degrees(Double(i) * (360.0 / Double(motionLineCount))))
            }
        }
        .frame(width: size, height: size)
    }
    
    var motionLineCount: Int {
        switch speed {
        case .off: return 0
        case .low: return 2
        case .medium: return 4
        case .high: return 6
        }
    }
}

struct FanBlade: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY),
                          control: CGPoint(x: rect.midX, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY),
                          control: CGPoint(x: rect.maxX, y: rect.midY))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.midY),
                          control: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
}

struct MotionLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        return path
    }
}
