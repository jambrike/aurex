# A.U.R.E.X. - AI Assistant iOS App

A futuristic AI assistant iOS app with OpenRouter integration, voice recognition, and a Jarvis-style interface.

## 🚀 Features

- **🎤 Voice Recognition**: Push-to-talk voice commands with real-time transcription
- **⌨️ Text Input**: Direct text input for commands and questions
- **🤖 AI Integration**: Powered by OpenRouter API (GPT-3.5-turbo)
- **💬 Real-time Responses**: Instant AI responses displayed in chat format
- **🔌 WebSocket Support**: Optional connection to external servers
- **🎨 Modern UI**: Futuristic Jarvis-style interface with animations
- **🔐 Secure Storage**: API keys stored securely using UserDefaults
- **📱 iOS Native**: Built with SwiftUI for optimal iOS experience

## 📋 Requirements

- **Xcode**: 15.0 or later
- **iOS**: 17.0 or later
- **Device**: iPhone or iPad with microphone
- **OpenRouter Account**: For AI functionality

## 🛠️ Build Instructions

### 1. Clone and Open Project

```bash
# Navigate to the iOS app directory
cd ios-app

# Open in Xcode
open AurexApp.xcodeproj
```

### 2. Configure API Key

The app comes pre-configured with an OpenRouter API key, but you can change it:

1. **In Settings**: Tap the gear icon → Enter your API key
2. **In Code**: Edit `ContentView.swift` line with `openRouterAPIKey`

### 3. Build and Run

1. **Select Target**: Choose your iOS device or simulator
2. **Build**: Press `Cmd + R` or click the Play button
3. **Permissions**: Grant microphone access when prompted

## 🎯 Usage Guide

### Voice Commands
1. **Tap the large circular button** to start recording
2. **Speak your question or command** clearly
3. **Release the button** to stop recording
4. **View AI response** below your command

### Text Commands
1. **Type in the text field** at the bottom
2. **Tap the send button** (arrow up icon)
3. **Get instant AI response**

### Settings
- **Gear Icon**: Access settings
- **Server IP**: Configure WebSocket server (optional)
- **API Key**: Manage OpenRouter API key

## 🔧 Technical Architecture

### Core Components

```
AurexApp/
├── AurexAppApp.swift          # App entry point
├── ContentView.swift          # Main UI and logic
├── OpenRouterService.swift    # AI API integration
├── Info.plist                # Permissions and config
└── Assets.xcassets/          # App icons and resources
```

### Key Classes

- **`ContentView`**: Main UI, speech recognition, command management
- **`OpenRouterService`**: Handles all AI API communication
- **`CommandManager`**: Manages commands and WebSocket connections
- **`SpeechRecognizer`**: Apple's Speech framework integration

### Permissions Required

- **Microphone**: For voice commands
- **Speech Recognition**: For voice-to-text conversion
- **Network**: For AI API calls and WebSocket connections

## 🧪 Testing

### Test Scenarios

1. **Voice Recognition**
   - Tap button → Speak → Verify transcription
   - Test with different accents and volumes

2. **AI Integration**
   - Ask questions: "What's the weather?"
   - Test commands: "Tell me a joke"
   - Verify responses appear in chat

3. **Text Input**
   - Type commands in text field
   - Test with long/short inputs
   - Verify send button behavior

4. **Error Handling**
   - Test with invalid API key
   - Test with no internet connection
   - Verify error indicators appear

### Debug Information

- **Console Logs**: Check Xcode console for API responses
- **Network Tab**: Monitor API calls in Xcode's network inspector
- **Memory Usage**: Monitor app performance

## 🔒 Security & Privacy

- **API Key Storage**: Securely stored in UserDefaults
- **Voice Data**: Processed locally, not stored
- **Network Security**: HTTPS for all API calls
- **Permissions**: Minimal required permissions

## 🐛 Troubleshooting

### Common Issues

**Build Errors**
- Ensure Xcode 15.0+ is installed
- Check iOS deployment target (17.0+)
- Verify all files are included in project

**Voice Recognition Issues**
- Grant microphone permissions
- Check device microphone settings
- Test in quiet environment

**AI Not Responding**
- Verify OpenRouter API key is valid
- Check internet connection
- Ensure OpenRouter account has credits

**App Crashes**
- Check console logs in Xcode
- Verify Info.plist permissions
- Test on different iOS versions

### Debug Commands

```bash
# Check project structure
find ios-app -name "*.swift" -o -name "*.plist"

# Verify Xcode project
xcodebuild -project ios-app/AurexApp.xcodeproj -list

# Build for testing
xcodebuild -project ios-app/AurexApp.xcodeproj -scheme AurexApp -destination 'platform=iOS Simulator,name=iPhone 15' build
```

## 📱 Deployment

### App Store Ready

The app is configured for App Store deployment:

- **Bundle Identifier**: Configure in Xcode
- **Signing**: Set up with your developer account
- **Capabilities**: Speech recognition enabled
- **Privacy**: Proper usage descriptions included

### Distribution

1. **Archive**: Product → Archive in Xcode
2. **Upload**: Use Xcode Organizer
3. **TestFlight**: For beta testing
4. **App Store**: For public release

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Make changes
4. Test thoroughly
5. Submit pull request

## 📄 License

This project is open source. See LICENSE file for details.

## 🆘 Support

For issues or questions:
1. Check troubleshooting section
2. Review console logs
3. Test on different devices
4. Create detailed bug report

---

**Ready to test!** 🚀

The app is now fully configured and ready for testing. Open in Xcode, build, and start using your AI assistant! 