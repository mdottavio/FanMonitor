import Cocoa

class FanView: NSView {
    private var fanSpeed: FanSpeed = .off
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.wantsLayer = true
        self.layer?.cornerRadius = frameRect.width / 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateColor(for speed: FanSpeed) {
        self.fanSpeed = speed
        self.setNeedsDisplay(self.bounds)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        
        // Clear the background
        context.clear(bounds)
        
        // Draw the fan circle
        context.setFillColor(fanSpeed.nsColor.cgColor)
        context.fillEllipse(in: bounds)
        
        // Draw fan blades
        drawFanBlades(in: context)
    }
    
    private func drawFanBlades(in context: CGContext) {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 2
        let bladeLength = radius * 0.8
        _ = radius * 0.2
        
        for i in 0..<3 {
            let angle = CGFloat(i) * (2 * .pi / 3)
            let startPoint = CGPoint(
                x: center.x + cos(angle) * (radius - bladeLength),
                y: center.y + sin(angle) * (radius - bladeLength)
            )
            let endPoint = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
            
            context.move(to: startPoint)
            context.addLine(to: endPoint)
            context.addArc(center: center, radius: radius, startAngle: angle - .pi/2, endAngle: angle + .pi/2, clockwise: false)
            context.closePath()
            
            context.setFillColor(NSColor.white.cgColor)
            context.fillPath()
        }
    }
    
    func updateTooltip(_ tooltip: String) {
        self.toolTip = tooltip
    }
}
