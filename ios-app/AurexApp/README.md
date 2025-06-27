# A.U.R.E.X. iOS App

A futuristic AI assistant iOS app with OpenRouter integration.

## Features

- **Voice Recognition**: Push-to-talk voice commands
- **Text Input**: Type commands directly
- **AI Integration**: Powered by OpenRouter API
- **Real-time Responses**: Get AI responses instantly
- **WebSocket Support**: Connect to external servers
- **Modern UI**: Jarvis-style interface with animations

## Setup

### 1. OpenRouter API Key

1. Go to [OpenRouter](https://openrouter.ai/) and create an account
2. Get your API key from the dashboard
3. Open the app and go to Settings (gear icon)
4. Enter your OpenRouter API key in the "OPENROUTER API KEY" field
5. The API key is securely stored and will persist between app launches

### 2. Server Connection (Optional)

If you want to connect to an external server:
1. Enter the server IP address in Settings
2. The app will attempt to connect via WebSocket

## Usage

### Voice Commands
- Tap the large circular button to start voice recording
- Speak your command or question
- The app will automatically send it to OpenRouter and display the response

### Text Commands
- Type your command in the text field at the bottom
- Tap the send button (arrow up icon)
- Get instant AI responses

### AI Responses
- All AI responses are displayed in purple boxes below your commands
- Loading indicators show when the AI is processing
- Error indicators appear if there are API issues

## Technical Details

- **Framework**: SwiftUI
- **AI Provider**: OpenRouter (GPT-3.5-turbo)
- **Speech Recognition**: Apple's Speech framework
- **Network**: URLSession for API calls, WebSocket for server communication
- **Storage**: UserDefaults for API key persistence

## Troubleshooting

### No AI Responses
- Check your OpenRouter API key in Settings
- Ensure you have an active internet connection
- Verify your OpenRouter account has sufficient credits

### Voice Recognition Issues
- Grant microphone permissions when prompted
- Speak clearly and in a quiet environment
- Check device microphone settings

### Connection Issues
- Verify the server IP address is correct
- Ensure the server is running and accessible
- Check network connectivity

## Privacy

- Your OpenRouter API key is stored locally on your device
- Voice recordings are processed locally and not stored
- Commands and responses are sent to OpenRouter for AI processing
- No data is stored on external servers except through OpenRouter 