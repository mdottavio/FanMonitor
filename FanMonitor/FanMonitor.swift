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
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkFanStatus()
        }
    }
    
    private func checkFanStatus() {
        fanSpeed = getFanSpeed()
    }
    
    private func getFanSpeed() -> Int {
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AppleSMC"))
        guard service != 0 else { return 0 }
        defer { IOServiceClose(service) }

        let connect = IOServiceOpen(service, mach_task_self_, 0, &connection)
        guard connect == kIOReturnSuccess else { return 0 }
        defer { IOServiceClose(connection) }

        var output = SMCOutput()
        let result = SMCCall(connection, .readFanSpeed, 0, &output)
        guard result == kIOReturnSuccess else { return 0 }

        return Int(output.value)
    }

    private var connection = io_connect_t()
}

extension Notification.Name {
    static let fanStatusChanged = Notification.Name("fanStatusChanged")
}

// Add these structures and enums at the end of the file
private struct SMCOutput {
    var value: UInt32 = 0
    var status: UInt8 = 0
    var data8: UInt8 = 0
    var data32: UInt32 = 0
}

private enum SMCSelector: UInt32 {
    case readFanSpeed = 5
}

private func SMCCall(_ connection: io_connect_t, _ selector: SMCSelector, _ input: UInt32, _ output: inout SMCOutput) -> kern_return_t {
    var inputStruct = SMCOutput(value: input)
    var outputStruct = SMCOutput()
    var outputSize = MemoryLayout<SMCOutput>.stride

    let result = IOConnectCallStructMethod(connection, selector.rawValue, &inputStruct, MemoryLayout<SMCOutput>.stride, &outputStruct, &outputSize)
    
    output = outputStruct
    return result
}
