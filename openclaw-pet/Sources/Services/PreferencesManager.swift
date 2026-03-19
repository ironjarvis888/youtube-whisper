//
//  PreferencesManager.swift
//  OpenClawPet
//
//  User preferences persistence
//

import Foundation

class PreferencesManager: ObservableObject {
    static let shared = PreferencesManager()
    
    private let defaults = UserDefaults.standard
    
    // Keys
    private enum Keys {
        static let characterColor = "characterColor"
        static let characterSize = "characterSize"
        static let animationStyle = "animationStyle"
        static let themeMode = "themeMode"
        static let chatBubbleStyle = "chatBubbleStyle"
        static let fontSize = "fontSize"
        static let weatherAlerts = "weatherAlerts"
        static let stockAlerts = "stockAlerts"
        static let messageAlerts = "messageAlerts"
        static let launchAtLogin = "launchAtLogin"
        static let enableNotifications = "enableNotifications"
    }
    
    // MARK: - Character Settings
    
    @Published var characterColor: String {
        didSet { defaults.set(characterColor, forKey: Keys.characterColor) }
    }
    
    @Published var characterSize: String {
        didSet { defaults.set(characterSize, forKey: Keys.characterSize) }
    }
    
    @Published var animationStyle: String {
        didSet { defaults.set(animationStyle, forKey: Keys.animationStyle) }
    }
    
    // MARK: - Theme Settings
    
    @Published var themeMode: String {
        didSet { defaults.set(themeMode, forKey: Keys.themeMode) }
    }
    
    // MARK: - Chat Settings
    
    @Published var chatBubbleStyle: String {
        didSet { defaults.set(chatBubbleStyle, forKey: Keys.chatBubbleStyle) }
    }
    
    @Published var fontSize: Double {
        didSet { defaults.set(fontSize, forKey: Keys.fontSize) }
    }
    
    // MARK: - Notification Settings
    
    @Published var weatherAlerts: Bool {
        didSet { defaults.set(weatherAlerts, forKey: Keys.weatherAlerts) }
    }
    
    @Published var stockAlerts: Bool {
        didSet { defaults.set(stockAlerts, forKey: Keys.stockAlerts) }
    }
    
    @Published var messageAlerts: Bool {
        didSet { defaults.set(messageAlerts, forKey: Keys.messageAlerts) }
    }
    
    @Published var enableNotifications: Bool {
        didSet { defaults.set(enableNotifications, forKey: Keys.enableNotifications) }
    }
    
    // MARK: - App Settings
    
    @Published var launchAtLogin: Bool {
        didSet { defaults.set(launchAtLogin, forKey: Keys.launchAtLogin) }
    }
    
    // MARK: - Init
    
    private init() {
        // Load saved preferences
        self.characterColor = defaults.string(forKey: Keys.characterColor) ?? "classicRed"
        self.characterSize = defaults.string(forKey: Keys.characterSize) ?? "medium"
        self.animationStyle = defaults.string(forKey: Keys.animationStyle) ?? "energetic"
        self.themeMode = defaults.string(forKey: Keys.themeMode) ?? "auto"
        self.chatBubbleStyle = defaults.string(forKey: Keys.chatBubbleStyle) ?? "bubble"
        self.fontSize = defaults.double(forKey: Keys.fontSize) == 0 ? 16 : defaults.double(forKey: Keys.fontSize)
        self.weatherAlerts = defaults.bool(forKey: Keys.weatherAlerts)
        self.stockAlerts = defaults.bool(forKey: Keys.stockAlerts)
        self.messageAlerts = defaults.bool(forKey: Keys.messageAlerts)
        self.enableNotifications = defaults.bool(forKey: Keys.enableNotifications)
        self.launchAtLogin = defaults.bool(forKey: Keys.launchAtLogin)
    }
    
    // MARK: - Methods
    
    func resetToDefaults() {
        characterColor = "classicRed"
        characterSize = "medium"
        animationStyle = "energetic"
        themeMode = "auto"
        chatBubbleStyle = "bubble"
        fontSize = 16
        weatherAlerts = true
        stockAlerts = true
        messageAlerts = true
        enableNotifications = true
        launchAtLogin = false
    }
    
    func export() -> [String: Any] {
        return [
            Keys.characterColor: characterColor,
            Keys.characterSize: characterSize,
            Keys.animationStyle: animationStyle,
            Keys.themeMode: themeMode,
            Keys.chatBubbleStyle: chatBubbleStyle,
            Keys.fontSize: fontSize,
            Keys.weatherAlerts: weatherAlerts,
            Keys.stockAlerts: stockAlerts,
            Keys.messageAlerts: messageAlerts,
            Keys.enableNotifications: enableNotifications,
            Keys.launchAtLogin: launchAtLogin
        ]
    }
    
    func import(from data: [String: Any]) {
        if let color = data[Keys.characterColor] as? String { characterColor = color }
        if let size = data[Keys.characterSize] as? String { characterSize = size }
        if let style = data[Keys.animationStyle] as? String { animationStyle = style }
        if let theme = data[Keys.themeMode] as? String { themeMode = theme }
        if let bubble = data[Keys.chatBubbleStyle] as? String { chatBubbleStyle = bubble }
        if let size = data[Keys.fontSize] as? Double { fontSize = size }
        if let weather = data[Keys.weatherAlerts] as? Bool { weatherAlerts = weather }
        if let stock = data[Keys.stockAlerts] as? Bool { stockAlerts = stock }
        if let message = data[Keys.messageAlerts] as? Bool { messageAlerts = message }
        if let notify = data[Keys.enableNotifications] as? Bool { enableNotifications = notify }
        if let launch = data[Keys.launchAtLogin] as? Bool { launchAtLogin = launch }
    }
}
