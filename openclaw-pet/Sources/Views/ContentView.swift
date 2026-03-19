//
//  ContentView.swift
//  OpenClawPet
//
//  Main content view with lobster character and chat
//

import SwiftUI

struct ContentView: View {
    @StateObject private var lobsterState = LobsterState.shared
    @StateObject private var settings = UserSettings.shared
    @State private var showChat = false
    
    var body: some View {
        ZStack {
            // 背景
            BackgroundView()
            
            // 龍蝦角色
            LobsterCharacterView()
                .position(lobsterState.position)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            lobsterState.position = value.location
                        }
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.3)) {
                        showChat.toggle()
                    }
                }
            
            // 對話氣泡
            if showChat {
                ChatBubbleView()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // 工具列
            VStack {
                HStack {
                    Spacer()
                    ToolbarView()
                        .padding()
                }
                Spacer()
            }
        }
        .frame(width: 400, height: 300)
        .background(Color.clear)
    }
}

struct BackgroundView: View {
    @ObservedObject var settings = UserSettings.shared
    
    var body: some View {
        if settings.isDarkMode {
            Color(hex: "1A1A2E")
                .ignoresSafeArea()
        } else {
            Color(hex: "FFFFFF")
                .ignoresSafeArea()
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
}
