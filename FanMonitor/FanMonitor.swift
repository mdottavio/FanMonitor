//
//  FanMonitor.swift
//  FanMonitor
//
//  Created by Mauricio Dottavio on 21/09/2024.
//

import Foundation

class FanMonitor {
    private var timer: Timer?
    var fanSpeed: Int = 0 {
        didSet {
            if fanSpeed != oldValue {
                NotificationCenter.default.post(name: .fanStatusChanged, object: nil)
            }
        }
    }
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.checkFanStatus()
        }
    }
    
    private func checkFanStatus() {
        fanSpeed = getFanSpeed()
    }
    
    private func getFanSpeed() -> Int {
        // This is a mock implementation
        return Int.random(in: 0...2000)
    }
}

extension Notification.Name {
    static let fanStatusChanged = Notification.Name("fanStatusChanged")
}
