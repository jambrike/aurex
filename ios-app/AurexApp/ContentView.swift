import SwiftUI
import Speech
import AVFoundation

struct ContentView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @StateObject private var commandManager = CommandManager()
    @State private var textInput = ""
    @State private var isRecording = false
    @State private var isConnected = false
    @State private var serverIP = "192.168.1.100"
    @State private var openRouterAPIKey = "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"
    @State private var showingSettings = false
    @State private var pulseAnimation = false
    @State private var glowAnimation = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color(red: 0.1, green: 0.1, blue: 0.2),
                    Color.black
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top status bar
                HStack {
                    // Connection status
                    HStack(spacing: 8) {
                        Circle()
                            .fill(isConnected ? Color.green : Color.red)
                            .frame(width: 8, height: 8)
                            .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseAnimation)
                        
                        Text(isConnected ? "ONLINE" : "OFFLINE")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(isConnected ? .green : .red)
                    }
                    
                    Spacer()
                    
                    // AI Status indicator
                    if !openRouterAPIKey.isEmpty {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.purple)
                                .frame(width: 8, height: 8)
                            
                            Text("AI READY")
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(.purple)
                        }
                    }
                    
                    // Error indicator
                    if let openRouterService = commandManager.openRouterService,
                       !openRouterService.lastError.isEmpty {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                            
                            Text("AI ERROR")
                                .font(.system(size: 12, weight: .medium, design: .monospaced))
                                .foregroundColor(.red)
                        }
                    }
                    
                    Spacer()
                    
                    // Settings button
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
                
                // Main Jarvis-style interface
                VStack(spacing: 30) {
                    // A.U.R.E.X. title
                    Text("A.U.R.E.X.")
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue)
                        .shadow(color: .blue.opacity(0.8), radius: 10, x: 0, y: 0)
                        .scaleEffect(glowAnimation ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: glowAnimation)
                    
                    // Main circular interface
                    ZStack {
                        // Outer ring
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue.opacity(0.3), .cyan.opacity(0.1)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 280, height: 280)
                            .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: pulseAnimation)
                        
                        // Middle ring
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue.opacity(0.5), .cyan.opacity(0.2)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                            .frame(width: 240, height: 240)
                            .scaleEffect(pulseAnimation ? 1.05 : 1.0)
                            .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: pulseAnimation)
                        
                        // Inner circle with push-to-talk button
                        Button(action: toggleRecording) {
                            ZStack {
                                // Background circle
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                isRecording ? Color.red : Color.blue.opacity(0.8),
                                                isRecording ? Color.red.opacity(0.6) : Color.cyan.opacity(0.6)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 180, height: 180)
                                    .shadow(color: isRecording ? .red.opacity(0.6) : .blue.opacity(0.6), radius: 20, x: 0, y: 0)
                                    .scaleEffect(isRecording ? 0.95 : 1.0)
                                    .animation(.easeInOut(duration: 0.2), value: isRecording)
                                
                                // Icon and text
                                VStack(spacing: 8) {
                                    Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                    
                                    Text(isRecording ? "STOP" : "PUSH TO TALK")
                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .disabled(!isConnected && openRouterAPIKey.isEmpty)
                        .scaleEffect(isRecording ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: isRecording)
                    }
                    
                    // Status text
                    VStack(spacing: 8) {
                        if isRecording {
                            Text("LISTENING...")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(.red)
                                .shadow(color: .red.opacity(0.8), radius: 5, x: 0, y: 0)
                        } else {
                            Text("READY")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(.blue)
                                .shadow(color: .blue.opacity(0.8), radius: 5, x: 0, y: 0)
                        }
                        
                        if !speechRecognizer.transcript.isEmpty {
                            Text("Heard: \(speechRecognizer.transcript)")
                                .font(.system(size: 14, design: .monospaced))
                                .foregroundColor(.cyan)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                    }
                }
                
                Spacer()
                
                // Bottom command input area
                VStack(spacing: 15) {
                    // Text input field
                    HStack {
                        TextField("Type command...", text: $textInput)
                            .font(.system(size: 16, design: .monospaced))
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.black.opacity(0.6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [.blue.opacity(0.5), .cyan.opacity(0.3)]),
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                            )
                        
                        // Send button
                        Button(action: sendTextCommand) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.blue)
                                .shadow(color: .blue.opacity(0.8), radius: 5, x: 0, y: 0)
                        }
                        .disabled(textInput.isEmpty || (!isConnected && openRouterAPIKey.isEmpty))
                    }
                    .padding(.horizontal, 20)
                    
                    // Command history with AI responses
                    if !commandManager.commandHistory.isEmpty {
                        ScrollView {
                            LazyVStack(spacing: 10) {
                                ForEach(commandManager.commandHistory.prefix(10), id: \.id) { command in
                                    CommandHistoryRow(command: command, openRouterService: commandManager.openRouterService)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .frame(maxHeight: 200)
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(serverIP: $serverIP, openRouterAPIKey: $openRouterAPIKey, isConnected: $isConnected)
        }
        .onAppear {
            setupSpeechRecognition()
            commandManager.connect(to: serverIP)
            pulseAnimation = true
            glowAnimation = true
            
            // Load saved API key
            if let savedAPIKey = UserDefaults.standard.string(forKey: "OpenRouterAPIKey") {
                openRouterAPIKey = savedAPIKey
            }
        }
        .onChange(of: speechRecognizer.transcript) { transcript in
            if !transcript.isEmpty && !isRecording {
                textInput = transcript
                sendTextCommand()
                speechRecognizer.transcript = ""
            }
        }
        .onChange(of: commandManager.isConnected) { connected in
            isConnected = connected
        }
        .onChange(of: openRouterAPIKey) { apiKey in
            if !apiKey.isEmpty {
                commandManager.setupOpenRouter(apiKey: apiKey)
                // Save API key
                UserDefaults.standard.set(apiKey, forKey: "OpenRouterAPIKey")
            }
        }
    }
    
    private func setupSpeechRecognition() {
        speechRecognizer.requestAuthorization()
    }
    
    private func toggleRecording() {
        if isRecording {
            speechRecognizer.stopRecording()
            isRecording = false
        } else {
            speechRecognizer.startRecording()
            isRecording = true
        }
    }
    
    private func sendTextCommand() {
        guard !textInput.isEmpty else { return }
        
        let command = Command(
            id: UUID(),
            text: textInput,
            timestamp: Date(),
            type: .text
        )
        
        commandManager.sendCommand(command)
        textInput = ""
    }
}

struct CommandHistoryRow: View {
    let command: Command
    @ObservedObject var openRouterService: OpenRouterService?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // User command
            HStack(spacing: 8) {
                Image(systemName: command.type == .voice ? "mic.fill" : "keyboard")
                    .font(.system(size: 12))
                    .foregroundColor(.blue)
                
                Text(command.text)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.white)
                    .lineLimit(3)
                
                Spacer()
                
                Text(command.timestamp, style: .time)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
            )
            
            // AI response or loading indicator
            if let aiResponse = command.aiResponse {
                HStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 12))
                        .foregroundColor(.purple)
                    
                    Text(aiResponse)
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundColor(.cyan)
                        .lineLimit(5)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.purple.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                        )
                )
            } else if openRouterService?.isLoading ?? false {
                HStack(spacing: 8) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 12))
                        .foregroundColor(.purple)
                    
                    HStack(spacing: 4) {
                        Text("Processing")
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(.cyan)
                        
                        ProgressView()
                            .scaleEffect(0.8)
                            .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.purple.opacity(0.2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
    }
}

struct SettingsView: View {
    @Binding var serverIP: String
    @Binding var openRouterAPIKey: String
    @Binding var isConnected: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color.black
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // A.U.R.E.X. title
                    Text("A.U.R.E.X. SETTINGS")
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue)
                        .shadow(color: .blue.opacity(0.8), radius: 10, x: 0, y: 0)
                    
                    // Settings form
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SERVER IP ADDRESS")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.blue)
                            
                            TextField("192.168.1.100", text: $serverIP)
                                .font(.system(size: 16, design: .monospaced))
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.black.opacity(0.6))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                                        )
                                )
                                .keyboardType(.numbersAndPunctuation)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("OPENROUTER API KEY")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(.blue)
                            
                            SecureField("Enter API key...", text: $openRouterAPIKey)
                                .font(.system(size: 16, design: .monospaced))
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.black.opacity(0.6))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                                        )
                                )
                        }
                        
                        Button("TEST CONNECTION") {
                            // Test connection logic
                        }
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue.opacity(0.5), lineWidth: 1)
                                )
                        )
                        
                        VStack(spacing: 10) {
                            HStack {
                                Text("VERSION")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(.blue)
                                Spacer()
                                Text("1.0.0")
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                            
                            HStack {
                                Text("STATUS")
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(.blue)
                                Spacer()
                                Text(isConnected ? "CONNECTED" : "DISCONNECTED")
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundColor(isConnected ? .green : .red)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black.opacity(0.4))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("DONE") {
                        dismiss()
                    }
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

// MARK: - Models

struct Command: Identifiable, Codable {
    let id: UUID
    let text: String
    let timestamp: Date
    let type: CommandType
    var aiResponse: String?
    
    enum CommandType: String, Codable {
        case voice
        case text
    }
}

// MARK: - Speech Recognizer

class SpeechRecognizer: NSObject, ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    @Published var transcript = ""
    @Published var isAuthorized = false
    
    override init() {
        super.init()
        speechRecognizer?.delegate = self
    }
    
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                self.isAuthorized = status == .authorized
            }
        }
    }
    
    func startRecording() {
        guard isAuthorized else { return }
        
        // Cancel any existing task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to configure audio session: \(error)")
            return
        }
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true
        
        // Start recognition
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.transcript = result.bestTranscription.formattedString
                }
            }
        }
        
        // Configure audio input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
    }
}

extension SpeechRecognizer: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        // Handle availability changes
    }
}

// MARK: - Command Manager

class CommandManager: ObservableObject {
    @Published var commandHistory: [Command] = []
    @Published var isConnected = false
    
    private var webSocket: URLSessionWebSocketTask?
    private let session = URLSession(configuration: .default)
    @Published var openRouterService: OpenRouterService?
    
    func setupOpenRouter(apiKey: String) {
        openRouterService = OpenRouterService(apiKey: apiKey)
    }
    
    func connect(to ipAddress: String) {
        guard let url = URL(string: "ws://\(ipAddress):8765") else { return }
        
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
        isConnected = true
        
        receiveMessage()
    }
    
    func disconnect() {
        webSocket?.cancel()
        webSocket = nil
        isConnected = false
    }
    
    func sendCommand(_ command: Command) {
        // Add to history immediately
        DispatchQueue.main.async {
            self.commandHistory.insert(command, at: 0)
            if self.commandHistory.count > 50 {
                self.commandHistory.removeLast()
            }
        }
        
        // Send to OpenRouter if available
        if let openRouterService = openRouterService {
            Task {
                if let response = await openRouterService.sendMessage(command.text) {
                    // Update the command with AI response
                    DispatchQueue.main.async {
                        if let index = self.commandHistory.firstIndex(where: { $0.id == command.id }) {
                            self.commandHistory[index].aiResponse = response
                        }
                    }
                }
            }
        }
        
        // Send via WebSocket if connected
        if isConnected {
            let message = URLSessionWebSocketTask.Message.string(command.text)
            webSocket?.send(message) { error in
                if let error = error {
                    print("Failed to send command: \(error)")
                }
            }
        }
    }
    
    private func receiveMessage() {
        webSocket?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received: \(text)")
                case .data(let data):
                    print("Received data: \(data)")
                @unknown default:
                    break
                }
                self?.receiveMessage()
            case .failure(let error):
                print("WebSocket error: \(error)")
                DispatchQueue.main.async {
                    self?.isConnected = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
} 