import Cocoa

class FanView: NSView {
    private var imageView: NSImageView!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        imageView = NSImageView(frame: bounds)
        imageView.image = NSImage(systemSymbolName: "fan", accessibilityDescription: "Fan")
        imageView.imageScaling = .scaleProportionallyUpOrDown
        addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func updateColor(for speed: FanSpeed) {
        imageView.contentTintColor = speed.color
    }
    
    override var intrinsicContentSize: NSSize {
        return NSSize(width: 18, height: 18)
    }
    
    func updateTooltip(_ tooltip: String) {
        self.toolTip = tooltip
    }
}
