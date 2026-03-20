//
//  ChatBubbleView.swift
//  OpenClawPet
//
//  Chat bubble component - using WebSocket Gateway
//

import SwiftUI
import Foundation

struct ChatBubbleView: View {
    @StateObject private var chatVM = ChatViewModel.shared
    @State private var inputText: String = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // 標題列
            HStack {
                Text("🦞 OpenClaw")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                HStack(spacing: 4) {
                    Circle()
                        .fill(chatVM.isConnected ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(chatVM.isConnected ? "連線中" : "離線")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)
            
            Divider()
            
            // 訊息列表
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(chatVM.messages) { message in
                            ChatMessageView(message: message)
                                .id(message.id)
                        }
                        
                        if chatVM.isLoading {
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("AI 思考中...")
                                    .foregroundColor(.secondary)
                            }
                            .padding(.leading, 16)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .onChange(of: chatVM.messages.count) { _, _ in
                    if let lastMessage = chatVM.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            .frame(height: 280)
            
            Divider()
            
            // 輸入框
            HStack(spacing: 12) {
                TextField("輸入訊息...", text: $inputText)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(20)
                    .focused($isInputFocused)
                    .onSubmit {
                        sendMessage()
                    }
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(inputText.isEmpty ? .gray : .blue)
                        .font(.system(size: 18))
                }
                .disabled(inputText.isEmpty || chatVM.isLoading)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .frame(width: 320, height: 420)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
    
    private func sendMessage() {
        guard !inputText.isEmpty else { return }
        chatVM.sendMessage(inputText)
        inputText = ""
    }
}

struct ChatMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isFromUser {
                Spacer(minLength: 40)
            }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 14))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(message.isFromUser ? Color.blue : Color.gray.opacity(0.15))
                    .foregroundColor(message.isFromUser ? .white : .primary)
                    .cornerRadius(18)
                
                Text(message.timeString)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            
            if !message.isFromUser {
                Spacer(minLength: 40)
            }
        }
    }
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let timestamp: Date
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

// MARK: - Chat ViewModel - Using WebSocket Gateway
class ChatViewModel: ObservableObject {
    static let shared = ChatViewModel()
    
    @Published var messages: [ChatMessage] = []
    @Published var isLoading: Bool = false
    @Published var isConnected: Bool = false
    
    private var webSocket: URLSessionWebSocketTask?
    private let gatewayURL = "ws://127.0.0.1:18789"
    private let authToken = "test-token-123"
    private var session: URLSession!
    
    private init() {
        session = URLSession(configuration: .default)
        
        messages.append(ChatMessage(
            text: "你好！我是 OpenClaw 🦞\n直接輸入訊息，我會用 AI 回覆你！",
            isFromUser: false,
            timestamp: Date()
        ))
        
        connectWebSocket()
    }
    
    private func connectWebSocket() {
        // 本地連線不需要 token
        guard let url = URL(string: gatewayURL) else { return }
        
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
        
        isConnected = true
        receiveMessage()
    }
    
    private func receiveMessage() {
        webSocket?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    DispatchQueue.main.async {
                        self?.handleMessage(text)
                    }
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        DispatchQueue.main.async {
                            self?.handleMessage(text)
                        }
                    }
                @unknown default:
                    break
                }
                self?.receiveMessage()
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.isConnected = false
                    print("WebSocket error: \(error)")
                    // 嘗試重連
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self?.connectWebSocket()
                    }
                }
            }
        }
    }
    
    private func handleMessage(_ text: String) {
        // 檢查是否包含回應
        if let data = text.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            
            // 檢查是否為對話回應
            if let text = json["text"] as? String {
                let response = ChatMessage(text: text, isFromUser: false, timestamp: Date())
                messages.append(response)
                isLoading = false
                return
            }
            
            // 檢查 content 欄位
            if let content = json["content"] as? String,
               !content.isEmpty {
                let response = ChatMessage(text: content, isFromUser: false, timestamp: Date())
                messages.append(response)
                isLoading = false
            }
        }
    }
    
    func sendMessage(_ text: String) {
        let userMessage = ChatMessage(text: text, isFromUser: true, timestamp: Date())
        messages.append(userMessage)
        
        isLoading = true
        
        // 發送到 Gateway
        let message: [String: Any] = [
            "action": "chat",
            "message": text,
            "channel": "app"
        ]
        
        guard let data = try? JSONSerialization.data(withJSONObject: message),
              let jsonString = String(data: data, encoding: .utf8) else { return }
        
        webSocket?.send(.string(jsonString)) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Send error: \(error)")
                    self.isLoading = false
                    // 顯示錯誤訊息
                    let errorMsg = ChatMessage(
                        text: "連線失敗，請稍後再試。",
                        isFromUser: false,
                        timestamp: Date()
                    )
                    self.messages.append(errorMsg)
                }
            }
        }
    }
}

#Preview {
    ChatBubbleView()
}
