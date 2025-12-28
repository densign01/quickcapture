# Brief macOS App

A native macOS application that integrates with Safari's share sheet to capture articles using your QuickCapture API.

## Features

- **Native macOS App**: Built with SwiftUI for a smooth macOS experience
- **Safari Share Extension**: Appears in Safari's share menu for one-click article capture
- **QuickCapture Integration**: Uses your existing QuickCapture API backend
- **AI Summaries**: Optional AI-generated summaries with configurable length
- **Local Preferences**: Email and settings stored securely on your Mac
- **Direct Install**: No App Store required - install directly as a .app bundle

## Installation

### Option 1: Build from Source

1. **Prerequisites**:
   - Xcode 15+ (for macOS 13+)
   - Your QuickCapture API endpoint URL

2. **Build the app**:
   ```bash
   cd brief-macos-app
   chmod +x build.sh
   ./build.sh
   ```

3. **Install**:
   - Open the generated `Brief-Installer.dmg`
   - Drag `Brief.app` to your Applications folder
   - Open Brief from Applications

### Option 2: Manual Xcode Build

1. Open `Brief.xcodeproj` in Xcode
2. Select the Brief scheme
3. Choose Product → Archive
4. Export as macOS app
5. Copy to Applications folder

## Setup

1. **Launch Brief** from your Applications folder
2. **Configure Settings**:
   - Click the gear icon in the top-right
   - Enter your email address
   - Set your QuickCapture API endpoint URL (e.g., `https://your-api.workers.dev`)
   - Click Done

3. **Enable Safari Extension**:
   - Open Safari
   - Go to Safari → Settings → Extensions
   - Find "Brief" and enable it
   - The extension will now appear in Safari's share menu

## Usage

### From Safari Share Menu

1. While viewing an article in Safari
2. Click the Share button (or right-click → Share)
3. Select "Brief" from the share menu
4. Optionally add a personal note
5. Configure AI summary settings
6. Click "Send" to capture the article

### From Main App

1. Open the Brief app
2. Paste or type an article URL
3. Click "Analyze" to extract the title
4. Add an optional personal note
5. Configure AI summary preferences
6. Click "Send to Email"

## Configuration

### API Endpoint

Set your QuickCapture API endpoint in the app settings. This should be the URL where your QuickCapture Worker is deployed (e.g., `https://quickcapture-api.your-domain.workers.dev`).

### AI Summaries

- **Short**: 3 bullet points, concise executive summary
- **Long**: 6 bullet points, detailed analysis

## Privacy & Security

- **Local Storage**: Email and preferences are stored locally on your Mac using macOS Keychain
- **No Data Collection**: The app doesn't collect or store any usage data
- **Direct API Communication**: Articles are sent directly to your QuickCapture API
- **Sandboxed**: The app runs in macOS sandbox for security

## Architecture

- **Main App**: SwiftUI-based interface for manual article capture and settings
- **Share Extension**: Native Safari extension for seamless integration
- **Shared Preferences**: App groups enable settings sharing between main app and extension
- **API Integration**: RESTful communication with your QuickCapture backend

## Troubleshooting

### Safari Extension Not Appearing

1. Make sure Brief.app is in your Applications folder
2. Restart Safari
3. Check Safari → Settings → Extensions
4. Enable the Brief extension

### "No Email Set" Error

1. Open the main Brief app
2. Click the gear icon
3. Enter your email address
4. Try the share extension again

### API Connection Issues

1. Verify your API endpoint URL in settings
2. Ensure your QuickCapture API is deployed and accessible
3. Check that CORS is properly configured in your Worker

## Development

The app is structured as:

- `Brief/` - Main SwiftUI application
- `Brief Share Extension/` - Safari share extension
- `build.sh` - Build and packaging script

### Customization

To customize for your own API:

1. Update the default API endpoint in `UserPreferences.swift`
2. Modify the API request structure in `APIService.swift` if needed
3. Adjust the UI in `ContentView.swift` for your branding

## Support

For issues or questions:

1. Check the QuickCapture API logs in Cloudflare Workers
2. Verify your API endpoint is accessible
3. Ensure email configuration is correct
4. Check Safari extension permissions

---

Built with ❤️ for seamless article capture on macOS.