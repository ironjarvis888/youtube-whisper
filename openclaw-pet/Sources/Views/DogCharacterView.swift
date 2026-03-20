//
//  DogCharacterView.swift
//  OpenClawPet
//
//  Cute dog character
//

import SwiftUI

struct DogCharacterView: View {
    @ObservedObject var settings = UserSettings.shared
    
    @State private var tailWag: CGFloat = 0
    @State private var isBlinking: Bool = false
    
    var body: some View {
        ZStack {
            // 身體
            VStack(spacing: 2) {
                // 頭
                Circle()
                    .fill(dogColor)
                    .frame(width: 60, height: 60)
                    .overlay(
                        // 臉
                        VStack(spacing: 4) {
                            // 眼睛
                            HStack(spacing: 15) {
                                DogEye(isBlinking: isBlinking)
                                DogEye(isBlinking: isBlinking)
                            }
                            // 鼻子
                            Ellipse()
                                .fill(Color.black)
                                .frame(width: 10, height: 8)
                            // 嘴巴
                            Image(systemName: "mouth.fill")
                                .resizable()
                                .frame(width: 14, height: 8)
                                .foregroundColor(.black)
                        }
                        .offset(y: -2)
                    )
                
                // 身體
                Ellipse()
                    .fill(dogColor)
                    .frame(width: 50, height: 40)
                    .offset(y: -5)
                
                // 尾巴
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 20))
                    .foregroundColor(dogColor)
                    .rotationEffect(.degrees(tailWag))
                    .offset(y: -8)
            }
            
            // 耳朵
            HStack(spacing: 30) {
                Image(systemName: "ear")
                    .font(.system(size: 16))
                    .foregroundColor(dogColor)
                    .offset(x: -20, y: -25)
                Image(systemName: "ear")
                    .font(.system(size: 16))
                    .foregroundColor(dogColor)
                    .offset(x: 20, y: -25)
            }
            
            // 狀態表情
            DogStatusEmoji()
        }
        .scaleEffect(settings.characterScale)
        .onAppear {
            startAnimations()
        }
    }
    
    var dogColor: Color {
        switch settings.characterColor {
        case .classicRed: return Color(hex: "D2691E") // 巧克力色
        case .oceanBlue: return Color(hex: "87CEEB") // 淺藍
        case .forestGreen: return Color(hex: "DEB887") // 米色
        case .dreamPurple: return Color(hex: "DDA0DD") // 紫色
        case .sakuraPink: return Color(hex: "FFB6C1") // 粉色
        }
    }
    
    private func startAnimations() {
        // 搖尾巴
        withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
            tailWag = 20
        }
        
        // 眨眼
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

struct DogEye: View {
    let isBlinking: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black)
                .frame(width: isBlinking ? 12 : 14, height: isBlinking ? 3 : 14)
            
            if !isBlinking {
                Circle()
                    .fill(Color.white)
                    .frame(width: 5, height: 5)
                    .offset(x: 2, y: -2)
            }
        }
    }
}

struct DogStatusEmoji: View {
    var body: some View {
        Text("🐕")
            .font(.system(size: 14))
            .offset(x: 35, y: -30)
    }
}

#Preview {
    DogCharacterView()
        .frame(width: 150, height: 150)
        .background(Color.gray.opacity(0.2))
}
