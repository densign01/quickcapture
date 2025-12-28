#!/bin/bash

# Brief macOS App Setup Script
# This script helps configure the app for first-time use

echo "🚀 Brief macOS App Setup"
echo "========================"

# Check if we're in the right directory
if [ ! -f "Brief.xcodeproj/project.pbxproj" ]; then
    echo "❌ Please run this script from the brief-macos-app directory"
    exit 1
fi

echo ""
echo "This script will help you set up Brief for your QuickCapture API."
echo ""

# Get API endpoint
read -p "Enter your QuickCapture API endpoint URL: " API_ENDPOINT

if [ -z "$API_ENDPOINT" ]; then
    echo "❌ API endpoint is required"
    exit 1
fi

# Update the default API endpoint in UserPreferences.swift
sed -i '' "s|https://quickcapture-api.your-domain.workers.dev|$API_ENDPOINT|g" Brief/UserPreferences.swift

echo "✅ Updated default API endpoint to: $API_ENDPOINT"

# Optional: Update bundle identifier
read -p "Enter a custom bundle identifier (or press Enter for default): " BUNDLE_ID

if [ ! -z "$BUNDLE_ID" ]; then
    # Update bundle identifiers in project file
    sed -i '' "s|com.quickcapture.brief|$BUNDLE_ID|g" Brief.xcodeproj/project.pbxproj
    sed -i '' "s|com.quickcapture.brief.shareextension|$BUNDLE_ID.shareextension|g" Brief.xcodeproj/project.pbxproj
    
    echo "✅ Updated bundle identifier to: $BUNDLE_ID"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Run './build.sh' to build the app"
echo "2. Install the generated DMG"
echo "3. Configure your email in the app settings"
echo "4. Enable the Safari extension in Safari settings"
echo ""
echo "For more information, see README.md"