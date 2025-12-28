# 🔧 Xcode Build Errors - Fix Guide

## ✅ **Code Fixed**
I've updated the Safari extension code to be compatible with older macOS versions by removing async/await and Task APIs.

## 🎯 **Next Steps in Xcode:**

### 1. **Set Deployment Targets**
For both the main app and extension targets:
1. Select your project in Xcode
2. Choose each target (Brief macOS and Brief Extension macOS)
3. **General Tab**:
   - Set **Deployment Target** to **macOS 13.0** (not 12.0)
4. **Build Settings**:
   - Search for "Deployment Target"
   - Set **macOS Deployment Target** to **13.0**

### 2. **Verify Framework Linking**
1. Select the **Brief Extension (macOS)** target
2. **Build Phases** tab
3. **Link Binary with Libraries**:
   - Ensure **Foundation.framework** is listed
   - Ensure **SafariServices.framework** is listed
   - If missing, click **+** and add them

### 3. **Check App Groups Configuration**
Both targets need the same App Group:
1. **Main App Target**: 
   - **Signing & Capabilities** → **App Groups** → `group.com.danielensign.Brief`
2. **Extension Target**: 
   - **Signing & Capabilities** → **App Groups** → `group.com.danielensign.Brief`

### 4. **Build Again**
1. **Clean Build Folder**: Product → Clean Build Folder (Cmd+Shift+K)
2. **Build**: Product → Build (Cmd+B)

## 🐛 **If You Still Get Errors:**

### Error: "init(priority:operation:)" not available
- **Solution**: The code has been updated to remove Task usage

### Error: "Task" not available  
- **Solution**: Replaced with DispatchQueue and completion handlers

### Error: "data(for:delegate:)" not available
- **Solution**: Replaced with classic dataTask(with:completionHandler:)

### Signing Issues
1. **Automatically manage signing**: Enable this in Signing & Capabilities
2. **Team**: Select your Apple ID or development team
3. **Bundle Identifier**: Make sure it's unique (e.g., `com.danielensign.Brief`)

## ✅ **What Should Work Now:**
- ✅ No async/await APIs (compatibility with older macOS)
- ✅ Uses URLSession.dataTask instead of data(for:)
- ✅ Uses DispatchQueue instead of Task
- ✅ Compatible with macOS 13.0+

## 🚀 **After Successful Build:**
1. **Run the main app** first
2. **Configure email and API endpoint**
3. **Test manual URL capture**
4. **Enable Safari extension** in Safari Settings
5. **Test extension** on article pages

The errors should now be resolved! Try building again in Xcode.