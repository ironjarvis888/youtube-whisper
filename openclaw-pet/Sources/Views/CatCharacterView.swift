//
//  CatCharacterView.swift
//  OpenClawPet
//
//  Cute cat character
//

import SwiftUI

struct CatCharacterView: View {
    @ObservedObject var settings = UserSettings.shared
    
    @State private var earTwitch: CGFloat = 0
    @State private var isBlinking: Bool = false
    
    var body: some View {
        ZStack {
            // 身體
            VStack(spacing: 0) {
                // 頭
                Circle()
                    .fill(catColor)
                    .frame(width: 55, height: 55)
                    .overlay(
                        // 臉
                        VStack(spacing: 2) {
                            // 眼睛
                            HStack(spacing: 18) {
                                CatEye(isBlinking: isBlinking)
                                CatEye(isBlinking: isBlinking)
                            }
                            // 鼻子
                            Triangle()
                                .fill(Color(hex: "FFB6C1"))
                                .frame(width: 6, height: 5)
                            // 嘴巴
                            HStack(spacing: 2) {
                                Image(systemName: "mouth.fill")
                                    .resizable()
                                    .frame(width: 6, height: 4)
                                Image(systemName: "mouth.fill")
                                    .resizable()
                                    .frame(width: 6, height: 4)
                            }
                            .offset(y: -2)
                        }
                        .offset(y: -2)
                    )
                
                // 身體
                Ellipse()
                    .fill(catColor)
                    .frame(width: 40, height: 35)
                    .offset(y: -8)
                
                // 尾巴
                Image(systemName: "waveform")
                    .font(.system(size: 20))
                    .foregroundColor(catColor)
                    .rotationEffect(.degrees(-30))
                    .offset(y: -15)
            }
            
            // 耳朵
            HStack(spacing: 25) {
                CatEar(color: catColor)
                    .rotationEffect(.degrees(earTwitch))
                    .offset(x: -15, y: -25)
                CatEar(color: catColor)
                    .rotationEffect(.degrees(-earTwitch))
                    .offset(x: 15, y: -25)
            }
            
            // 狀態表情
            CatStatusEmoji()
        }
        .scaleEffect(settings.characterScale)
        .onAppear {
            startAnimations()
        }
    }
    
    var catColor: Color {
        switch settings.characterColor {
        case .classicRed: return Color(hex: "FF8C00") // 橘貓
        case .oceanBlue: return Color(hex: "87CEEB") // 藍貓
        case .forestGreen: return Color(hex: "90EE90") // 綠貓
        case .dreamPurple: return Color(hex: "DDA0DD") // 紫貓
        case .sakuraPink: return Color(hex: "FFC0CB") // 粉貓
        }
    }
    
    private func startAnimations() {
        // 耳朵動
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            earTwitch = 10
        }
        
        // 眨眼
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
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

struct CatEye: View {
    let isBlinking: Bool
    
    var body: some View {
        ZStack {
            // 眼睛
            if isBlinking {
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 12, height: 2)
            } else {
                Ellipse()
                    .fill(Color.black)
                    .frame(width: 12, height: 14)
                    .overlay(
                        // 瞳孔
                        Ellipse()
                            .fill(Color.green)
                            .frame(width: 8, height: 10)
                    )
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 3, height: 3)
                            .offset(x: -2, y: -2)
                    )
            }
        }
    }
}

struct CatEar: View {
    let color: Color
    
    var body: some View {
        Triangle()
            .fill(color)
            .frame(width: 18, height: 20)
            .overlay(
                Triangle()
                    .fill(Color(hex: "FFB6C1"))
                    .frame(width: 8, height: 10)
            )
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

struct CatStatusEmoji: View {
    var body: some View {
        Text("🐱")
            .font(.system(size: 14))
            .offset(x: 30, y: -30)
    }
}

#Preview {
    CatCharacterView()
        .frame(width: 150, height: 150)
        .background(Color.gray.opacity(0.2))
}
