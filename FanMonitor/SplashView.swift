//
//  SplashView.swift
//  FanMonitor
//
//  Created by Mauricio Dottavio on 22/09/2024.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Fan Monitor")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("To monitor your fan speed, Fan Monitor needs Full Disk Access. Please follow these steps:")
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("1. Click 'Open System Preferences' below")
                Text("2. Go to 'Security & Privacy' > 'Privacy' tab")
                Text("3. Select 'Full Disk Access' from the left sidebar")
                Text("4. Click the lock to make changes")
                Text("5. Click the '+' button and add Fan Monitor")
                Text("6. Restart Fan Monitor")
            }
            
            Button("Open System Preferences") {
                openSystemPreferences()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
    
    private func openSystemPreferences() {
        let urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
}

