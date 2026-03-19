//
//  UserSettings.swift
//  OpenClawPet
//
//  User preferences and settings
//

import Foundation
import SwiftUI
import Combine

class UserSettings: ObservableObject {
    static let shared = UserSettings()
    
    // MARK: - Character Settings
    @Published var characterColor: CharacterColor = .classicRed
    @Published var characterSize: CharacterSize = .medium
    @Published var animationStyle: AnimationStyle = .energetic
    @Published var currentAccessory: Accessory = .none
    
    // MARK: - Theme Settings
    @Published var themeMode: ThemeMode = .auto
    @Published var accentColor: Color = Color(hex: "FF6B6B")
    
    // MARK: - Chat Settings
    @Published var chatBubbleStyle: ChatBubbleStyle = .bubble
    @Published var fontSize: CGFloat = 16
    
    // MARK: - Notification Settings
    @Published var weatherAlerts: Bool = true
    @Published var stockAlerts: Bool = true
    @Published var messageAlerts: Bool = true
    
    // MARK: - Computed Properties
    var characterScale: CGFloat {
        characterSize.scale
    }
    
    var isDarkMode: Bool {
        switch themeMode {
        case .light: return false
        case .dark: return true
        case .auto: return false // TODO: Detect system setting
        }
    }
    
    // MARK: - Init
    private init() {
        load()
    }
    
    // MARK: - Persistence
    func save() {
        // TODO: Save to UserDefaults
        print("Settings saved")
    }
    
    func load() {
        // TODO: Load from UserDefaults
        print("Settings loaded")
    }
}
