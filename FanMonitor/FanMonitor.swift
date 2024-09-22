import Foundation
import IOKit
import os.log
import AppKit  

class FanMonitor {
    private var timer: Timer?
    private var currentSpeed: Int = 0
    
    func startMonitoring(interval: TimeInterval = 5.0) {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.updateFanSpeed()
        }
        timer?.fire() // Initial update
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateFanSpeed() {
        let newSpeed = getFanSpeed()
        if newSpeed != currentSpeed {
            currentSpeed = newSpeed
            NotificationCenter.default.post(name: .fanSpeedDidChange, object: nil, userInfo: ["speed": newSpeed])
        }
    }
    
    private func getFanSpeed() -> Int {
        let mainPort: mach_port_t
        if #available(macOS 12.0, *) {
            mainPort = kIOMainPortDefault
        } else {
            mainPort = kIOMasterPortDefault
        }

        let service = IOServiceGetMatchingService(mainPort, IOServiceMatching("AppleSMC"))
        guard service != IO_OBJECT_NULL else {
            os_log("Failed to get AppleSMC service", type: .error)
            return 0
        }
        defer { IOObjectRelease(service) }

        var connection = io_connect_t()
        let connect = IOServiceOpen(service, mach_task_self_, 0, &connection)
        if connect != kIOReturnSuccess {
            if connect == kIOReturnNotPrivileged {
                os_log("The application does not have the required privileges to access fan speed", type: .error)
                DispatchQueue.main.async {
                    self.promptForFullDiskAccess()
                }
            } else {
                os_log("Failed to open service. Error code: %{public}d", type: .error, connect)
            }
            return 0
        }
        defer { IOServiceClose(connection) }

        let fanSpeed = readSMCKey(connection: connection, key: "F0Ac") // Try "F1Ac" if this doesn't work
        os_log("Fan speed: %{public}d RPM", type: .debug, fanSpeed)
        return fanSpeed
    }

    private func promptForFullDiskAccess() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Additional Permissions Required"
            alert.informativeText = "Fan Monitor needs Full Disk Access to read fan speeds. Please grant this permission in System Preferences."
            alert.addButton(withTitle: "Open System Preferences")
            alert.addButton(withTitle: "Cancel")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                self.openSystemPreferencesFullDiskAccess()
            }
        }
    }

    private func openSystemPreferencesFullDiskAccess() {
        let urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        }
    }

    private func getAlternativeFanSpeed() -> Int {
        // Implement an alternative method to get fan speed
        // This could involve running a shell command or using a different API
        // For now, we'll return a mock value
        return 1000 // Mock value
    }

    private func readSMCKey(connection: io_connect_t, key: String) -> Int {
        var inputStruct = SMCKeyData_t()
        var outputStruct = SMCKeyData_t()

        inputStruct.key = stringToFourCharCode(key)
        inputStruct.data8 = SMC_CMD_READ_KEYINFO

        let inputStructSize = MemoryLayout<SMCKeyData_t>.size
        var outputStructSize = MemoryLayout<SMCKeyData_t>.size

        let result = IOConnectCallStructMethod(connection, UInt32(KERNEL_INDEX_SMC), &inputStruct, inputStructSize, &outputStruct, &outputStructSize)

        if result != kIOReturnSuccess {
            os_log("Error reading SMC key info: %{public}d", type: .error, result)
            return 0
        }

        inputStruct.keyInfo.dataSize = outputStruct.keyInfo.dataSize
        inputStruct.data8 = SMC_CMD_READ_BYTES

        let readResult = IOConnectCallStructMethod(connection, UInt32(KERNEL_INDEX_SMC), &inputStruct, inputStructSize, &outputStruct, &outputStructSize)

        if readResult != kIOReturnSuccess {
            os_log("Error reading SMC: %{public}d", type: .error, readResult)
            return 0
        }

        return Int(outputStruct.bytes.0) * 256 + Int(outputStruct.bytes.1)
    }

    private func stringToFourCharCode(_ str: String) -> UInt32 {
        let chars = Array(str.utf8)
        return UInt32(chars[0]) << 24 | UInt32(chars[1]) << 16 | UInt32(chars[2]) << 8 | UInt32(chars[3])
    }
}

// Constants and structures
private let KERNEL_INDEX_SMC: UInt32 = 2

private let SMC_CMD_READ_BYTES: UInt8 = 5
private let SMC_CMD_READ_KEYINFO: UInt8 = 9

private struct SMCKeyData_t {
    var key: UInt32 = 0
    var vers = SMCVersion()
    var pLimitData: UInt16 = 0
    var keyInfo = SMCKeyInfoData()
    var padding: UInt32 = 0
    var result: UInt8 = 0
    var status: UInt8 = 0
    var data8: UInt8 = 0
    var data32: UInt32 = 0
    var bytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
}

private struct SMCVersion {
    var major: UInt8 = 0
    var minor: UInt8 = 0
    var build: UInt8 = 0
    var reserved: UInt8 = 0
    var release: UInt16 = 0
}

private struct SMCKeyInfoData {
    var dataSize: UInt32 = 0
    var dataType: UInt32 = 0
    var dataAttributes: UInt8 = 0
}

extension Notification.Name {
    static let fanSpeedDidChange = Notification.Name("fanSpeedDidChange")
}
