import SwiftUI

struct FanIcon: View {
    enum Speed {
        case off, low, medium, high
    }
    
    let speed: Speed
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Base fan shape
            Circle()
                .stroke(lineWidth: 2)
            
            ForEach(0..<3) { i in
                Rectangle()
                    .fill(Color.primary)
                    .frame(width: size * 0.1, height: size * 0.4)
                    .offset(y: -size * 0.2)
                    .rotationEffect(.degrees(Double(i) * 120))
            }
            
            // Motion lines
            switch speed {
            case .off:
                EmptyView()
            case .low:
                MotionLines(count: 3, length: size * 0.2)
            case .medium:
                MotionLines(count: 6, length: size * 0.3)
            case .high:
                MotionLines(count: 12, length: size * 0.4)
            }
        }
        .frame(width: size, height: size)
    }
}

struct MotionLines: View {
    let count: Int
    let length: CGFloat
    
    var body: some View {
        ForEach(0..<count, id: \.self) { i in
            Path { path in
                path.move(to: CGPoint(x: 0, y: length))
                path.addLine(to: CGPoint(x: 0, y: 0))
            }
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [2, 2]))
            .rotationEffect(.degrees(Double(i) * (360.0 / Double(count))))
        }
    }
}

struct FanIcon_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 20) {
            FanIcon(speed: .off, size: 50)
            FanIcon(speed: .low, size: 50)
            FanIcon(speed: .medium, size: 50)
            FanIcon(speed: .high, size: 50)
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
