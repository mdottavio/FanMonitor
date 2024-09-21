import Cocoa
import SwiftUI

class MenuBarManager {
    private var statusItem: NSStatusItem?
    private let fanMonitor: FanMonitor
    private var fanIconView: FanIconView?
    private var menu: NSMenu?
    
    init(fanMonitor: FanMonitor = FanMonitor()) {
        self.fanMonitor = fanMonitor
        setupMenuBar()
        setupFanMonitor()
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            let buttonFrame = button.frame
            let iconSize: CGFloat = min(buttonFrame.width, buttonFrame.height) - 4
            
            fanIconView = FanIconView(frame: NSRect(x: 0, y: 0, width: iconSize, height: iconSize))
            fanIconView?.updateIcon(for: .off)
            
            button.addSubview(fanIconView!)
            
            // Center the fanIconView in the button
            fanIconView?.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                fanIconView!.centerXAnchor.constraint(equalTo: button.centerXAnchor),
                fanIconView!.centerYAnchor.constraint(equalTo: button.centerYAnchor),
                fanIconView!.widthAnchor.constraint(equalToConstant: iconSize),
                fanIconView!.heightAnchor.constraint(equalToConstant: iconSize)
            ])
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
        fanIconView?.updateIcon(for: fanSpeed)
        updateTooltip(speed: speed)
        updateMenu(speed: speed, status: fanSpeed)
    }
    
    private func updateTooltip(speed: Int) {
        let tooltip = "Fan Speed: \(speed) RPM"
        statusItem?.button?.toolTip = tooltip
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
