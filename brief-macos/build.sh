#!/bin/bash

# Brief macOS App Build Script
# This script builds the Brief app and creates a distributable DMG

set -e

APP_NAME="Brief"
PROJECT_NAME="Brief.xcodeproj"
SCHEME_NAME="Brief"
BUILD_DIR="build"
ARCHIVE_PATH="${BUILD_DIR}/${APP_NAME}.xcarchive"
EXPORT_PATH="${BUILD_DIR}/export"
DMG_NAME="Brief-Installer"

echo "🏗️  Building Brief macOS App..."

# Clean and create build directory
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "📦 Archiving the app..."
xcodebuild archive \
    -project "$PROJECT_NAME" \
    -scheme "$SCHEME_NAME" \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=macOS" \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

echo "📱 Exporting the app..."
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist exportOptions.plist

# Find the exported app
APP_PATH=$(find "$EXPORT_PATH" -name "*.app" -type d)

if [ -z "$APP_PATH" ]; then
    echo "❌ App not found in export directory"
    exit 1
fi

echo "📦 Creating DMG installer..."

# Create temporary DMG directory
DMG_DIR="${BUILD_DIR}/dmg"
mkdir -p "$DMG_DIR"

# Copy app to DMG directory
cp -R "$APP_PATH" "$DMG_DIR/"

# Create symbolic link to Applications folder
ln -s /Applications "$DMG_DIR/Applications"

# Create DMG
hdiutil create -volname "$APP_NAME" \
    -srcfolder "$DMG_DIR" \
    -ov -format UDZO \
    "${BUILD_DIR}/${DMG_NAME}.dmg"

echo "✅ Build complete!"
echo "📁 App: $APP_PATH"
echo "💿 DMG: ${BUILD_DIR}/${DMG_NAME}.dmg"
echo ""
echo "To install:"
echo "1. Open the DMG file"
echo "2. Drag Brief.app to your Applications folder"
echo "3. Open Brief from Applications and configure your email"
echo "4. The Safari share extension will be available in Safari's share menu"