# Brief macOS App - Installation Guide

## Quick Install

You've successfully built the Brief macOS app! Here's how to install and use it:

### Step 1: Install the App

1. **Open the DMG**:
   ```bash
   open build/Brief-Installer.dmg
   ```

2. **Drag to Applications**: When the DMG opens, drag `Brief.app` to the Applications folder.

3. **First Launch**: 
   - Right-click on Brief.app in Applications
   - Select "Open" (this bypasses Gatekeeper since it's unsigned)
   - Click "Open" in the security dialog

### Step 2: Configure the App

1. **Set your email**: Enter your email address where you want to receive articles
2. **Set API endpoint**: Enter `https://quickcapture-api.daniel-ensign.workers.dev`
3. **Close settings**

### Step 3: Test the Main App

1. **Paste a URL**: Try pasting a news article URL
2. **Click Analyze**: This will extract the title
3. **Optional**: Add a personal note
4. **Optional**: Enable AI summary
5. **Click Send**: The article should be sent to your email

## Safari Extension (Manual Setup)

Since we built this without Xcode's full extension support, the Safari extension needs to be added manually:

### Option 1: Use the Main App
- The main Brief app works perfectly for manual article capture
- Just copy URLs from Safari and paste them into Brief

### Option 2: Create Safari Extension (Advanced)
If you want the Safari integration:

1. Open Xcode
2. Create a new Safari Extension project
3. Copy the share extension code from `Brief Share Extension/ShareViewController.swift`
4. Build and install through Xcode

## Usage

### Main App Workflow
1. Copy an article URL from Safari
2. Open Brief app
3. Paste the URL and click "Analyze"
4. Configure AI summary options
5. Add personal notes (optional)
6. Click "Send to Email"

### Features
- ✅ **AI Summaries**: Powered by your Claude API
- ✅ **Local Storage**: Email and preferences saved securely
- ✅ **Direct API**: Connects to your QuickCapture backend
- ✅ **Clean Interface**: Native macOS design

## Troubleshooting

### App Won't Open
- Right-click → Open (don't double-click the first time)
- Allow unsigned app in Security & Privacy settings

### API Connection Issues
1. Verify your API endpoint: `https://quickcapture-api.daniel-ensign.workers.dev`
2. Test it manually:
   ```bash
   curl -X POST https://quickcapture-api.daniel-ensign.workers.dev \
     -H "Content-Type: application/json" \
     -d '{"url":"https://example.com","title":"Test","email":"test@example.com"}'
   ```

### Email Not Received
1. Check your API logs in Cloudflare Dashboard
2. Verify your Resend API key is set in Worker environment variables
3. Check spam folder

## Next Steps

Your Brief app is now ready to use! You can:

1. **Distribute to others**: Share the DMG file with anyone who wants to use your QuickCapture service
2. **Add features**: Modify the Swift code to add new functionality
3. **Create Safari Extension**: Use Xcode to build a proper Safari extension
4. **Sign the app**: Get a Developer ID to remove security warnings

Enjoy your new native macOS article capture app! 🎉