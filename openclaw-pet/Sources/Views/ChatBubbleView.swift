//
//  ChatBubbleView.swift
//  OpenClawPet
//
//  Chat bubble component
//

import SwiftUI

struct ChatBubbleView: View {
    @StateObject private var chatVM = ChatViewModel.shared
    @State private var inputText: String = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // 標題列
            HStack {
                Text("與 OpenClaw 對話")
                    .font(.headline)
                Spacer()
                Button(action: { /* TODO: 最小化 */ }) {
                    Image(systemName: "minus")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // 訊息列表
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(chatVM.messages) { message in
                        ChatMessageView(message: message)
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 200)
            
            // 輸入框
            HStack {
                TextField("輸入訊息...", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .focused($isInputFocused)
                    .onSubmit {
                        sendMessage()
                    }
                
                Button(action: sendMessage) {
                    Image(systemName: "paperplane.fill")
                }
                .disabled(inputText.isEmpty)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(16)
        .shadow(radius: 10)
        .frame(width: 320)
        .padding(.bottom, 80)
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
        HStack {
            if message.isFromUser {
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 14))
                    .padding(10)
                    .background(message.isFromUser ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(message.isFromUser ? .white : .primary)
                    .cornerRadius(12)
                
                Text(message.timeString)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !message.isFromUser {
                Spacer()
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

// MARK: - Chat ViewModel
class ChatViewModel: ObservableObject {
    static let shared = ChatViewModel()
    
    @Published var messages: [ChatMessage] = []
    @Published var isLoading: Bool = false
    
    private init() {}
    
    func sendMessage(_ text: String) {
        // Add user message
        let userMessage = ChatMessage(text: text, isFromUser: true, timestamp: Date())
        messages.append(userMessage)
        
        // TODO: Send to OpenClaw Gateway
        // For now, add a placeholder response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let response = ChatMessage(text: "收到訊息: \(text)", isFromUser: false, timestamp: Date())
            self.messages.append(response)
        }
    }
}

#Preview {
    ChatBubbleView()
}
