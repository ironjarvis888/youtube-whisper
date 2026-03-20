//
//  LobsterCharacterView.swift
//  OpenClawPet
//
//  Cute cartoon lobster character
//

import SwiftUI

struct LobsterCharacterView: View {
    @StateObject private var state = LobsterState.shared
    @ObservedObject var settings = UserSettings.shared
    
    @State private var tentacleOffset: CGFloat = 0
    @State private var isBlinking: Bool = false
    
    var body: some View {
        ZStack {
            // 身體 - 橢圓形
            VStack(spacing: 0) {
                // 尾巴
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { _ in
                        Ellipse()
                            .fill(Color(hex: settings.characterColor.hex))
                            .frame(width: 12, height: 20)
                    }
                }
                .offset(y: 5)
                
                // 身體
                Ellipse()
                    .fill(Color(hex: settings.characterColor.hex))
                    .frame(width: 70, height: 50)
                    .overlay(
                        // 肚子的淺色部分
                        Ellipse()
                            .fill(Color.white.opacity(0.4))
                            .frame(width: 35, height: 25)
                            .offset(x: -5, y: 5)
                    )
                
                // 觸手 (短短的)
                HStack(spacing: 15) {
                    ForEach(0..<2, id: \.self) { _ in
                        Image(systemName: "antenna")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: settings.characterColor.hex).opacity(0.8))
                    }
                }
                .offset(y: -5)
            }
            
            // 臉部 - 大眼睛
            VStack(spacing: 6) {
                HStack(spacing: 20) {
                    // 左眼
                    CuteEye(isBlinking: isBlinking)
                    // 右眼
                    CuteEye(isBlinking: isBlinking)
                }
                
                // 嘴巴
                CuteMouth(mood: state.mood)
            }
            .offset(y: -5)
            
            // 狀態指示
            StatusEmoji(mood: state.mood)
        }
        .scaleEffect(settings.characterScale)
        .onAppear {
            startAnimations()
            startBlinking()
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            tentacleOffset = -3
        }
    }
    
    private func startBlinking() {
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                isBlinking = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isBlinking = false
                }
            }
        }
    }
}

// 可愛眼睛
struct CuteEye: View {
    let isBlinking: Bool
    
    var body: some View {
        ZStack {
            // 眼眶
            Circle()
                .fill(Color.black)
                .frame(width: 22, height: 22)
            
            // 眼白
            if isBlinking {
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 22, height: 3)
            } else {
                Circle()
                    .fill(Color.white)
                    .frame(width: 14, height: 14)
                
                // 瞳孔
                Circle()
                    .fill(Color.black)
                    .frame(width: 10, height: 10)
                
                // 高光
                Circle()
                    .fill(Color.white)
                    .frame(width: 4, height: 4)
                    .offset(x: -2, y: -2)
            }
        }
    }
}

// 可愛嘴巴
struct CuteMouth: View {
    let mood: LobsterMood
    
    var body: some View {
        Group {
            switch mood {
            case .happy:
                Text("▽")
                    .font(.system(size: 16))
                    .offset(y: 2)
            case .sleeping:
                Text("~")
                    .font(.system(size: 14, weight: .bold))
            case .surprised:
                Circle()
                    .fill(Color.black)
                    .frame(width: 6, height: 6)
            case .talking:
                Text("◡")
                    .font(.system(size: 14))
            default:
                Text("‿")
                    .font(.system(size: 12))
            }
        }
    }
}

// 狀態表情
struct StatusEmoji: View {
    let mood: LobsterMood
    
    var body: some View {
        Group {
            switch mood {
            case .happy:
                Text("💕")
                    .font(.system(size: 16))
                    .offset(x: 35, y: -25)
            case .thinking:
                Text("💭")
                    .font(.system(size: 14))
                    .offset(x: 30, y: -25)
            case .sleeping:
                Text("💤")
                    .font(.system(size: 14))
                    .offset(x: 30, y: -25)
            case .alert:
                Text("❗")
                    .font(.system(size: 16))
                    .offset(x: 30, y: -25)
            case .talking:
                Text("💬")
                    .font(.system(size: 14))
                    .offset(x: 35, y: -25)
            default:
                EmptyView()
            }
        }
    }
}

#Preview {
    LobsterCharacterView()
        .frame(width: 150, height: 150)
        .background(Color.gray.opacity(0.2))
}
