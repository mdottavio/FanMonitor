import Cocoa

class MenuBarManager {
    private var statusItem: NSStatusItem?
    private let fanMonitor = FanMonitor()
    private var fanView: FanView?
    private var menu: NSMenu?
    
    init() {
        setupMenuBar()
        setupFanMonitor()
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            let buttonFrame = button.frame
            let fanViewSize: CGFloat = min(buttonFrame.width, buttonFrame.height) - 2
            let fanViewFrame = CGRect(x: (buttonFrame.width - fanViewSize) / 2,
                                      y: (buttonFrame.height - fanViewSize) / 2,
                                      width: fanViewSize,
                                      height: fanViewSize)
            
            fanView = FanView(frame: fanViewFrame)
            button.addSubview(fanView!)
        }
        
        setupMenu()
        updateFanStatus(speed: 0)
    }
    
    private func setupMenu() {
        menu = NSMenu()
        menu?.addItem(NSMenuItem(title: "Current Fan Speed: 0 RPM", action: nil, keyEquivalent: ""))
        menu?.addItem(NSMenuItem(title: "Fan Status: Off", action: nil, keyEquivalent: ""))
        menu?.addItem(NSMenuItem.separator())
        
        let openActivityMonitorItem = NSMenuItem(title: "Open Activity Monitor", action: #selector(openActivityMonitor), keyEquivalent: "")
        openActivityMonitorItem.target = self
        menu?.addItem(openActivityMonitorItem)
        
        menu?.addItem(NSMenuItem.separator())
        menu?.addItem(NSMenuItem(title: "Quit Fan Monitor", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc private func openActivityMonitor() {
        let activityMonitorURL = URL(fileURLWithPath: "/System/Applications/Utilities/Activity Monitor.app")
        
        NSWorkspace.shared.openApplication(at: activityMonitorURL,
                                           configuration: NSWorkspace.OpenConfiguration(),
                                           completionHandler: { (application, error) in
            if let error = error {
                print("Failed to open Activity Monitor: \(error.localizedDescription)")
            }
        })
    }
    
    private func setupFanMonitor() {
        fanMonitor.startMonitoring()
        NotificationCenter.default.addObserver(self, selector: #selector(fanStatusChanged), name: .fanStatusChanged, object: nil)
    }
    
    @objc private func fanStatusChanged() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let speed = self.fanMonitor.fanSpeed
            self.updateFanStatus(speed: speed)
        }
    }
    
    private func updateFanStatus(speed: Int) {
        let fanSpeed = getFanSpeed(for: speed)
        fanView?.updateColor(for: fanSpeed)
        updateTooltip(speed: speed)
        updateMenu(speed: speed, status: fanSpeed)
    }
    
    private func updateTooltip(speed: Int) {
        let tooltip = "Fan Speed: \(speed) RPM"
        fanView?.updateTooltip(tooltip)
    }
    
    private func updateMenu(speed: Int, status: FanSpeed) {
        menu?.item(at: 0)?.title = "Current Fan Speed: \(speed) RPM"
        menu?.item(at: 1)?.title = "Fan Status: \(status)"
    }
    
    private func getFanSpeed(for speed: Int) -> FanSpeed {
        switch speed {
        case 0: return .off
        case 1...500: return .low
        case 501...1500: return .medium
        default: return .high
        }
    }
}
