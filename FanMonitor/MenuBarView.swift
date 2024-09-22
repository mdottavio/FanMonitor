import SwiftUI

struct MenuBarView: View {
    @ObservedObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if appState.hasFullDiskAccess {
                Text("Fan Speed: \(appState.fanSpeed) RPM")
                    .font(.headline)
                Text("Status: \(fanStatus)")
                    .font(.subheadline)
            } else {
                Text("Full Disk Access Required")
                    .font(.headline)
                Button("Grant Access") {
                    openSystemPreferences()
                }
                .buttonStyle(.borderedProminent)
            }
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding()
        .frame(width: 200)
    }
    
    private var fanStatus: String {
        switch appState.fanSpeed {
        case 0: return "Off"
        case 1...500: return "Low"
        case 501...1500: return "Medium"
        default: return "High"
        }
    }
    
    private func openSystemPreferences() {
        let urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }
}
