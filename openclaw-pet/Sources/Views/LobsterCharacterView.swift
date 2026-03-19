//
//  LobsterCharacterView.swift
//  OpenClawPet
//
//  The main lobster character view with animations
//

import SwiftUI

struct LobsterCharacterView: View {
    @StateObject private var state = LobsterState.shared
    @ObservedObject var settings = UserSettings.shared
    
    var body: some View {
        ZStack {
            // 龍蝦身體
            LobsterBodyView(color: settings.characterColor)
            
            // 觸手動畫
            TentaclesView(mood: state.mood)
            
            // 表情
            FacialExpressionView(mood: state.mood)
            
            // 配件 (如果有)
            if let accessory = settings.currentAccessory {
                AccessoryView(type: accessory)
            }
            
            // 狀態指示 (如 sleeping Zzz)
            StatusIndicatorView()
        }
        .scaleEffect(settings.characterScale)
    }
}

struct LobsterBodyView: View {
    let color: CharacterColor
    
    var body: some View {
        Ellipse()
            .fill(Color(hex: color.hex))
            .frame(width: 80, height: 60)
            .overlay(
                Ellipse()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 30, height: 20)
                    .offset(x: -15, y: -10)
            )
    }
}

struct TentaclesView: View {
    let mood: LobsterMood
    
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<6, id: \.self) { index in
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: CharacterColor.classicRed.hex).opacity(0.8))
                    .frame(width: 6, height: 25)
                    .offset(y: animationOffset + CGFloat(index % 2) * 5)
            }
        }
        .offset(y: 35)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever()) {
                animationOffset = -5
            }
        }
    }
}

struct FacialExpressionView: View {
    let mood: LobsterMood
    
    var body: some View {
        VStack(spacing: 4) {
            // 眼睛
            HStack(spacing: 12) {
                EyeView(state: mood.eyeState)
                EyeView(state: mood.eyeState)
            }
            
            // 嘴巴
            MouthView(state: mood)
        }
        .offset(y: -10)
    }
}

struct EyeView: View {
    let state: EyeState
    
    var body: some View {
        Circle()
            .fill(Color.black)
            .frame(width: state == .surprised ? 14 : 10, height: state == .surprised ? 14 : 10)
            .overlay(
                Circle()
                    .fill(Color.white)
                    .frame(width: 4, height: 4)
                    .offset(x: 2, y: -2)
            )
    }
}

struct MouthView: View {
    let state: LobsterMood
    
    var body: some View {
        switch state {
        case .happy:
            Image(systemName: "mouth")
                .resizable()
                .frame(width: 16, height: 8)
        case .sleeping:
            Text("~")
                .font(.system(size: 14, weight: .bold))
        default:
            RoundedRectangle(cornerRadius: 4)
                .frame(width: 12, height: 4)
        }
    }
}

struct AccessoryView: View {
    let type: Accessory
    
    var body: some View {
        // 配件視圖 - 實現帽子、眼鏡等
        Image(systemName: type.iconName)
            .font(.system(size: 24))
            .offset(y: -40)
    }
}

struct StatusIndicatorView: View {
    @StateObject private var state = LobsterState.shared
    
    var body: some View {
        VStack {
            if state.mood == .sleeping {
                SleepingIndicatorView()
            }
            if state.mood == .alert {
                AlertIndicatorView()
            }
        }
        .offset(x: 40, y: -30)
    }
}

struct SleepingIndicatorView: View {
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack(spacing: 2) {
            Text("Z")
                .font(.system(size: 12, weight: .bold))
            Text("z")
                .font(.system(size: 10, weight: .bold))
            Text("z")
                .font(.system(size: 8, weight: .bold))
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeInOut(duration: 1).repeatForever()) {
                opacity = 1
            }
        }
    }
}

struct AlertIndicatorView: View {
    @State private var scale: CGFloat = 1
    
    var body: some View {
        Text("!")
            .font(.system(size: 16, weight: .bold))
            .foregroundColor(.white)
            .frame(width: 20, height: 20)
            .background(Color.red)
            .clipShape(Circle())
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.3).repeatForever()) {
                    scale = 1.2
                }
            }
    }
}

#Preview {
    LobsterCharacterView()
        .frame(width: 200, height: 200)
        .background(Color.gray.opacity(0.2))
}
