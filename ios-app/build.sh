#!/bin/bash

# A.U.R.E.X. iOS App Build Script
# This script helps build and test the iOS app

echo "🚀 A.U.R.E.X. iOS App Build Script"
echo "=================================="

# Check if we're in the right directory
if [ ! -f "AurexApp.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: Please run this script from the ios-app directory"
    echo "   Current directory: $(pwd)"
    echo "   Expected: ios-app/"
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode is not installed or not in PATH"
    echo "   Please install Xcode from the App Store"
    exit 1
fi

echo "✅ Xcode found: $(xcodebuild -version | head -n 1)"

# Check project structure
echo ""
echo "📁 Checking project structure..."
if [ ! -f "AurexApp/ContentView.swift" ]; then
    echo "❌ Error: ContentView.swift not found"
    exit 1
fi

if [ ! -f "AurexApp/OpenRouterService.swift" ]; then
    echo "❌ Error: OpenRouterService.swift not found"
    exit 1
fi

if [ ! -f "AurexApp/Info.plist" ]; then
    echo "❌ Error: Info.plist not found"
    exit 1
fi

echo "✅ All required files found"

# List available simulators
echo ""
echo "📱 Available iOS Simulators:"
xcrun simctl list devices available | grep "iPhone\|iPad" | head -10

# Build the project
echo ""
echo "🔨 Building project..."
xcodebuild -project AurexApp.xcodeproj -scheme AurexApp -destination 'platform=iOS Simulator,name=iPhone 15' build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
else
    echo "❌ Build failed!"
    exit 1
fi

echo ""
echo "🎉 A.U.R.E.X. iOS App is ready!"
echo ""
echo "📋 Next steps:"
echo "   1. Open AurexApp.xcodeproj in Xcode"
echo "   2. Select your target device (iPhone/iPad)"
echo "   3. Press Cmd+R to build and run"
echo "   4. Grant microphone permissions when prompted"
echo "   5. Start using your AI assistant!"
echo ""
echo "🔧 Features available:"
echo "   • Voice commands (tap the big button)"
echo "   • Text input (type at bottom)"
echo "   • AI responses via OpenRouter"
echo "   • Settings (gear icon)"
echo ""
echo "🤖 Your OpenRouter API key is pre-configured"
echo "   You can change it in Settings if needed" 