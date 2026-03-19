//
//  OpenClawGateway.swift
//  OpenClawPet
//
//  Communication with OpenClaw Gateway
//

import Foundation

class OpenClawGateway: ObservableObject {
    static let shared = OpenClawGateway()
    
    @Published var isConnected: Bool = false
    @Published var lastMessage: String = ""
    @Published var messages: [ChatMessage] = []
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession?
    private let gatewayURL = "ws://127.0.0.1:18789"
    private let authToken = "840e3ee6001dfd55d10bab8082f9cbcb4423ce4fb9e7289a"
    
    private init() {
        session = URLSession(configuration: .default)
    }
    
    // MARK: - Connection
    
    func connect() {
        guard let url = URL(string: "\(gatewayURL)?token=\(authToken)") else {
            print("Invalid Gateway URL")
            return
        }
        
        webSocketTask = session?.webSocketTask(with: url)
        webSocketTask?.resume()
        
        isConnected = true
        receiveMessage()
        
        print("Connected to OpenClaw Gateway")
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        isConnected = false
        print("Disconnected from OpenClaw Gateway")
    }
    
    // MARK: - Messaging
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    DispatchQueue.main.async {
                        self?.lastMessage = text
                        self?.handleMessage(text)
                    }
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        DispatchQueue.main.async {
                            self?.lastMessage = text
                            self?.handleMessage(text)
                        }
                    }
                @unknown default:
                    break
                }
                
                // Continue listening
                self?.receiveMessage()
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.isConnected = false
                    print("WebSocket error: \(error)")
                }
            }
        }
    }
    
    func sendMessage(_ text: String) {
        let message = """
        {"type":"message","content":"\(text)","channel":"app"}
        """
        
        webSocketTask?.send(.string(message)) { error in
            if let error = error {
                print("Send error: \(error)")
            }
        }
        
        // Add user message to local list
        DispatchQueue.main.async {
            let userMsg = ChatMessage(text: text, isFromUser: true, timestamp: Date())
            self.messages.append(userMsg)
        }
    }
    
    private func handleMessage(_ text: String) {
        // Parse JSON response from Gateway
        // For now, just add to messages
        let responseMsg = ChatMessage(text: text, isFromUser: false, timestamp: Date())
        messages.append(responseMsg)
    }
    
    // MARK: - API Methods
    
    func sendChatMessage(_ text: String, completion: @escaping (String?) -> Void) {
        let message = """
        {"action":"chat","message":"\(text)","model":"MiniMax-M2.5"}
        """
        
        webSocketTask?.send(.string(message)) { error in
            if let error = error {
                completion(nil)
                print("Send error: \(error)")
                return
            }
            
            // Wait for response (simplified)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                completion("Response from OpenClaw")
            }
        }
    }
}
