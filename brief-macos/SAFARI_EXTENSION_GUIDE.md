# Safari Share Extension Setup Guide

## 🎯 Current Status
Your Brief app works perfectly as a standalone application, but to appear in Safari's share sheet, you need to create a proper Safari extension using Xcode.

## 🔄 **Option 1: Current Workflow (Works Now!)**

### Step 1: Browse in Safari
- Navigate to any article you want to capture

### Step 2: Copy the URL
- Press `Cmd+L` to select the URL bar
- Press `Cmd+C` to copy the URL

### Step 3: Open Brief
- Open Brief from your Applications folder
- Or use Spotlight: `Cmd+Space` → type "Brief" → Enter

### Step 4: Capture Article
- Paste the URL (`Cmd+V`) into the URL field
- Click "Analyze" to extract the title
- Add personal notes if desired
- Configure AI summary options
- Click "Send to Email"

**This workflow is actually quite fast and works reliably!**

## 🛠️ **Option 2: Safari Share Extension (Advanced)**

To get the Safari share sheet integration, follow these steps:

### Prerequisites
- Xcode installed
- Apple Developer Account (free tier works)
- Understanding of Xcode project setup

### Steps to Create Safari Extension

1. **Open Xcode**
   ```bash
   open /Applications/Xcode.app
   ```

2. **Create New Safari Extension Project**
   - File → New → Project
   - Choose "Safari Extension App" (macOS)
   - Product Name: "Brief Safari Extension"
   - Bundle Identifier: `com.quickcapture.brief.safari`

3. **Replace Extension Code**
   - Replace the generated `SafariWebExtensionHandler.swift` with our share logic
   - Copy the API integration code from `Brief/APIService.swift`
   - Add the same UI elements for note-taking and AI options

4. **Configure Extension Manifest**
   ```json
   {
     "manifest_version": 3,
     "name": "Brief",
     "version": "1.0",
     "permissions": ["activeTab"],
     "action": {
       "default_popup": "popup.html"
     }
   }
   ```

5. **Build and Install**
   - Build the project in Xcode
   - Install the extension
   - Enable in Safari → Settings → Extensions

### Why This Is Complex
- **Code Signing**: Safari extensions must be properly signed
- **Entitlements**: Require specific security permissions
- **App Store**: Eventually need to distribute through App Store for full functionality
- **Debugging**: Extension debugging is more complex than regular apps

## 🎯 **Recommendation: Use Current Workflow**

For most users, the **copy-paste workflow is actually very efficient**:

### Advantages of Current Approach:
- ✅ **Works immediately** - no additional setup needed
- ✅ **More reliable** - no browser extension issues
- ✅ **Full functionality** - all features available
- ✅ **Better UI** - native macOS interface vs cramped extension popup
- ✅ **No signing issues** - works without developer certificates

### Quick Keyboard Workflow:
1. In Safari: `Cmd+L` → `Cmd+C` (copy URL)
2. `Cmd+Space` → "Brief" → `Enter` (open app)
3. `Cmd+V` → Click "Analyze" → Configure → Send

**Total time: ~5 seconds**

## 🔧 **Alternative: Browser Bookmarklet**

You could also create a bookmarklet that automatically opens Brief with the current URL:

```javascript
javascript:(function(){
  const url = encodeURIComponent(window.location.href);
  const title = encodeURIComponent(document.title);
  window.open(`brief://capture?url=${url}&title=${title}`);
})();
```

Save this as a bookmark and click it to send the current page to Brief.

## 💡 **Future Enhancement**

If you really want Safari integration, the cleanest approach would be to:

1. **Use the current app** for the core functionality
2. **Create a simple Safari extension** that just captures URL+title
3. **Send data to the main app** via URL scheme or shared container
4. **Let the main app handle** the API calls and email sending

This keeps the complex logic in your proven Swift app while adding just the minimal Safari integration needed.

---

**Bottom Line**: Your current Brief app is fully functional and the copy-paste workflow is actually quite smooth for regular use!