# FanMonitor

FanMonitor is a macOS application that displays your Mac's fan speed in the menu bar. It provides real-time monitoring of your system's cooling performance.

## Features

- Real-time fan speed monitoring
- Menu bar integration for easy access
- Low resource usage

## Requirements

- macOS 11.0 or later
- Xcode 12.0 or later (for building from source)

## Installation

### Option 1: Download the pre-built application

1. Go to the [Releases](https://github.com/mdottavio/FanMonitor/releases) page.
2. Download the latest `FanMonitor.app.zip` file.
3. Unzip the file and move `FanMonitor.app` to your Applications folder.

### Option 2: Build from source

1. Clone the repository:
   ```
   git clone https://github.com/mdottavio/FanMonitor.git
   ```
2. Open `FanMonitor.xcodeproj` in Xcode.
3. Build the project (Product > Build).
4. Run the app (Product > Run) or export it (Product > Archive > Export).

## Usage

1. Launch FanMonitor from your Applications folder.
2. Grant Full Disk Access when prompted (required to read fan speed data).
3. The fan speed will appear in your menu bar.
4. Click the menu bar icon to see more details or quit the application.

## Granting Full Disk Access

FanMonitor requires Full Disk Access to read fan speed data. To grant this:

1. Open System Preferences > Security & Privacy > Privacy tab.
2. Select "Full Disk Access" from the left sidebar.
3. Click the lock icon to make changes.
4. Click the "+" button and add FanMonitor.app.
5. Restart FanMonitor if it's already running.

## Troubleshooting

- If you don't see fan speed data, ensure you've granted Full Disk Access.
- If the app doesn't appear in the Full Disk Access list, manually add it using the "+" button.
- For any other issues, please [open an issue](https://github.com/mdottavio/FanMonitor/issues) on GitHub.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [SMCKit](https://github.com/beltex/SMCKit) for SMC access code inspiration.
- [SwiftUI](https://developer.apple.com/xcode/swiftui/) for the user interface framework.

## Disclaimer

This software is provided as-is, without any warranties. Use at your own risk. Always ensure your Mac has proper cooling and ventilation.
