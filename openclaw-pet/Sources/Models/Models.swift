//
//  Models.swift
//  OpenClawPet
//
//  Data models for the app
//

import Foundation
import SwiftUI

// MARK: - Character Color
enum CharacterColor: String, CaseIterable, Identifiable {
    case classicRed = "經典紅"
    case oceanBlue = "海洋藍"
    case forestGreen = "森林綠"
    case dreamPurple = "夢幻紫"
    case sakuraPink = "櫻花粉"
    
    var id: String { rawValue }
    
    var hex: String {
        switch self {
        case .classicRed: return "FF6B6B"
        case .oceanBlue: return "74B9FF"
        case .forestGreen: return "55EFC4"
        case .dreamPurple: return "A29BFE"
        case .sakuraPink: return "FD79A8"
        }
    }
}

// MARK: - Character Size
enum CharacterSize: String, CaseIterable, Identifiable {
    case small = "小"
    case medium = "中"
    case large = "大"
    
    var id: String { rawValue }
    
    var scale: CGFloat {
        switch self {
        case .small: return 0.5
        case .medium: return 1.0
        case .large: return 1.5
        }
    }
}

// MARK: - Character Accessory
enum Accessory: String, CaseIterable, Identifiable {
    case none = "無"
    case hat = "帽子"
    case glasses = "眼鏡"
    case tie = "領帶"
    case backpack = "揹包"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .none: return ""
        case .hat: return "cap.fill"
        case .glasses: return "eyeglasses"
        case .tie: return "tie.fill"
        case .backpack: return "backpack.fill"
        }
    }
}

// MARK: - Animation Style
enum AnimationStyle: String, CaseIterable, Identifiable {
    case energetic = "活潑"
    case relaxed = "悠閒"
    case cool = "帥氣"
    
    var id: String { rawValue }
}

// MARK: - Chat Bubble Style
enum ChatBubbleStyle: String, CaseIterable, Identifiable {
    case bubble = "氣泡式"
    case notes = "筆記型"
    case floating = "浮動式"
    case fullscreen = "全螢幕"
    
    var id: String { rawValue }
}

// MARK: - Theme Mode
enum ThemeMode: String, CaseIterable, Identifiable {
    case light = "亮色"
    case dark = "暗色"
    case auto = "自動"
    
    var id: String { rawValue }
}

// MARK: - Lobster Mood
enum LobsterMood {
    case happy
    case thinking
    case surprised
    case sleeping
    case talking
    case alert
    
    var eyeState: EyeState {
        switch self {
        case .happy, .talking: return .open
        case .thinking: return .closed
        case .surprised, .alert: return .surprised
        case .sleeping: return .sleeping
        }
    }
}

enum EyeState {
    case open
    case closed
    case surprised
    case sleeping
}

// MARK: - Pet Type
enum PetType: String, CaseIterable, Identifiable {
    case lobster = "龍蝦"
    case dog = "小狗"
    case cat = "小貓"
    
    var id: String { rawValue }
    
    var emoji: String {
        switch self {
        case .lobster: return "🦞"
        case .dog: return "🐕"
        case .cat: return "🐱"
        }
    }
}
