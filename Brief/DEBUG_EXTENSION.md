# 🔧 Safari Extension Debug Steps

## ✅ **I've Updated the Extension Code**

The extension was getting stuck because it wasn't properly communicating between the popup and native app. I've fixed:

- ✅ **Better error handling** in popup.js
- ✅ **Proper message routing** through background.js  
- ✅ **Enhanced logging** for debugging

## 🔄 **Next Steps:**

### **1. Rebuild the Extension**
In Xcode:
1. **Select "Brief Extension (macOS)" scheme**
2. **Product → Clean Build Folder** (Cmd+Shift+K)
3. **Product → Build** (Cmd+B)
4. **Product → Run** (Cmd+R)

### **2. Reload Extension in Safari**
1. **Safari → Settings → Extensions**
2. **Turn OFF Brief extension**
3. **Turn ON Brief extension** again
4. **Or restart Safari entirely**

### **3. Check Settings in Main App**
1. **Open Brief app**
2. **Settings (gear icon)**
3. **Verify:**
   - ✅ Email: `your-email@example.com`
   - ✅ API Endpoint: `https://quickcapture-api.daniel-ensign.workers.dev`

### **4. Test Again**
1. **Go to any article page**
2. **Click Brief extension icon**
3. **Click "Send to Email"**
4. **Watch for success/error message**

## 🔍 **Enhanced Debugging:**

### **Check Safari Console:**
1. **Safari → Develop → Web Extension Background Pages → Brief**
2. **Console tab** - look for:
   - "Received request" messages
   - "Processing article capture" 
   - "Native app response" or errors

### **If Still Stuck at "Capturing article...":**

**Possible issues:**
1. **Email not set** in main app
2. **API endpoint wrong** in main app  
3. **App groups not configured** properly
4. **Extension permissions** not granted

**Quick test:**
1. **Try the main Brief app** with same URL first
2. **If main app works**, extension should work too
3. **If main app fails**, fix that first

## ✅ **Expected Behavior Now:**

- ✅ Click extension → Shows popup
- ✅ Click "Send to Email" → Shows "Capturing article..."  
- ✅ Success → Shows "Article sent successfully!" → Popup closes
- ✅ Error → Shows specific error message

The extension should now provide better feedback about what's happening instead of getting stuck indefinitely.