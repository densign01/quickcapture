#!/bin/bash

# Simple build script for Brief app using swiftc directly
set -e

APP_NAME="Brief"
BUILD_DIR="build"
APP_BUNDLE="${BUILD_DIR}/${APP_NAME}.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "🏗️  Building Brief macOS App..."

# Clean and create build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

echo "📝 Creating Info.plist..."
cat > "${CONTENTS_DIR}/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.quickcapture.brief</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleDisplayName</key>
    <string>${APP_NAME}</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025. All rights reserved.</string>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.productivity</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
</dict>
</plist>
EOF

echo "🔨 Compiling Swift files for Apple Silicon..."
# Detect the current architecture
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    TARGET_ARCH="arm64-apple-macosx13.0"
    echo "   Building for Apple Silicon (arm64)..."
else
    TARGET_ARCH="x86_64-apple-macosx13.0"
    echo "   Building for Intel (x86_64)..."
fi

swiftc -target $TARGET_ARCH \
    Brief/BriefApp.swift \
    Brief/ContentView.swift \
    Brief/UserPreferences.swift \
    Brief/APIService.swift \
    -framework SwiftUI \
    -framework Foundation \
    -framework AppKit \
    -o "${MACOS_DIR}/${APP_NAME}"

if [ $? -ne 0 ]; then
    echo "❌ Compilation failed"
    exit 1
fi

# Create app icon bundle
if [ -d "Brief/Assets.xcassets/AppIcon.appiconset" ]; then
    echo "📱 Creating app icon bundle..."
    
    # Create AppIcon.icns from individual PNG files
    ICONSET_DIR="${BUILD_DIR}/AppIcon.iconset"
    mkdir -p "$ICONSET_DIR"
    
    # Copy icons with proper naming for iconutil
    cp "Brief/Assets.xcassets/AppIcon.appiconset/icon-16.png" "$ICONSET_DIR/icon_16x16.png" 2>/dev/null || true
    cp "Brief/Assets.xcassets/AppIcon.appiconset/icon-32.png" "$ICONSET_DIR/icon_16x16@2x.png" 2>/dev/null || true
    cp "Brief/Assets.xcassets/AppIcon.appiconset/icon-32.png" "$ICONSET_DIR/icon_32x32.png" 2>/dev/null || true
    cp "Brief/Assets.xcassets/AppIcon.appiconset/icon-64.png" "$ICONSET_DIR/icon_32x32@2x.png" 2>/dev/null || true
    cp "Brief/Assets.xcassets/AppIcon.appiconset/icon-128.png" "$ICONSET_DIR/icon_128x128.png" 2>/dev/null || true
    cp "Brief/Assets.xcassets/AppIcon.appiconset/icon-256.png" "$ICONSET_DIR/icon_128x128@2x.png" 2>/dev/null || true
    cp "Brief/Assets.xcassets/AppIcon.appiconset/icon-256.png" "$ICONSET_DIR/icon_256x256.png" 2>/dev/null || true
    cp "Brief/Assets.xcassets/AppIcon.appiconset/icon-512.png" "$ICONSET_DIR/icon_256x256@2x.png" 2>/dev/null || true
    cp "Brief/Assets.xcassets/AppIcon.appiconset/icon-512.png" "$ICONSET_DIR/icon_512x512.png" 2>/dev/null || true
    cp "Brief/Assets.xcassets/AppIcon.appiconset/icon-1024.png" "$ICONSET_DIR/icon_512x512@2x.png" 2>/dev/null || true
    
    # Create .icns file
    iconutil -c icns "$ICONSET_DIR" -o "${RESOURCES_DIR}/AppIcon.icns"
    
    # Clean up
    rm -rf "$ICONSET_DIR"
fi

echo "📦 Creating DMG..."
DMG_DIR="${BUILD_DIR}/dmg"
mkdir -p "$DMG_DIR"
cp -R "$APP_BUNDLE" "$DMG_DIR/"
ln -s /Applications "$DMG_DIR/Applications"

hdiutil create -volname "Brief Installer" \
    -srcfolder "$DMG_DIR" \
    -ov -format UDZO \
    "${BUILD_DIR}/Brief-Installer.dmg"

echo "✅ Build complete!"
echo "📁 App: $APP_BUNDLE"
echo "💿 DMG: ${BUILD_DIR}/Brief-Installer.dmg"
echo ""
echo "To install:"
echo "1. Open the DMG file"
echo "2. Drag Brief.app to your Applications folder"
echo "3. Open Brief and configure your settings"