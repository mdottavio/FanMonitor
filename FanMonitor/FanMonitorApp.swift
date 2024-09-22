//
//  FanMonitorApp.swift
//  FanMonitor
//
//  Created by Mauricio Dottavio on 21/09/2024.
//

import SwiftUI

@main
struct FanMonitorApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        MenuBarExtra("Fan Monitor", systemImage: "fan") {
            MenuBarView(appState: appState)
        }
        .menuBarExtraStyle(.window)
        
        Window("Fan Monitor Setup", id: "splash") {
            SplashView()
        }
        .defaultSize(width: 400, height: 450)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .onChange(of: appState.hasFullDiskAccess) { oldValue, newValue in
            if newValue {
                NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "splash" })?.close()
            }
        }
    }
}

class AppState: ObservableObject {
    @Published var hasFullDiskAccess: Bool = false
    @Published var fanSpeed: Int = 0
    private var fanMonitor: FanMonitor?
    
    init() {
        checkFullDiskAccess()
    }
    
    func checkFullDiskAccess() {
        let fileManager = FileManager.default
        let filePath = "/Library/Application Support/com.apple.TCC/TCC.db"
        hasFullDiskAccess = fileManager.isReadableFile(atPath: filePath)
        if hasFullDiskAccess {
            startMonitoring()
        }
    }
    
    private func startMonitoring() {
        fanMonitor = FanMonitor()
        fanMonitor?.startMonitoring()
        NotificationCenter.default.addObserver(self, selector: #selector(updateFanSpeed), name: .fanSpeedDidChange, object: nil)
    }
    
    @objc private func updateFanSpeed(_ notification: Notification) {
        if let speed = notification.userInfo?["speed"] as? Int {
            DispatchQueue.main.async {
                self.fanSpeed = speed
            }
        }
    }
}
