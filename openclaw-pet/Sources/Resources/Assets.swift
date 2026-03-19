//
//  Assets.xcassets
//  OpenClawPet
//
//  Asset catalog for images and colors
//

import SwiftUI

// MARK: - Color Assets
extension Color {
    static let lobsterRed = Color(hex: "FF6B6B")
    static let lobsterBlue = Color(hex: "74B9FF")
    static let lobsterGreen = Color(hex: "55EFC4")
    static let lobsterPurple = Color(hex: "A29BFE")
    static let lobsterPink = Color(hex: "FD79A8")
    
    static let primaryBackground = Color(hex: "FFFFFF")
    static let darkBackground = Color(hex: "1A1A2E")
    static let surfaceColor = Color(hex: "F7F7F7")
    static let textPrimary = Color(hex: "2D3436")
    static let textSecondary = Color(hex: "636E72")
    static let accentColor = Color(hex: "FF6B6B")
}

// MARK: - Image Assets
// Placeholder for asset names - add actual images to Assets.xcassets
enum AssetImage: String {
    case lobsterIdle = "lobster_idle"
    case lobsterTalk = "lobster_talk"
    case lobsterSleep = "lobster_sleep"
    case lobsterHappy = "lobster_happy"
    case accessoryHat = "accessory_hat"
    case accessoryGlasses = "accessory_glasses"
    case iconWeather = "icon_weather"
    case iconStocks = "icon_stocks"
    case iconSettings = "icon_settings"
}

// MARK: - SF Symbols
enum AppSymbol: String {
    case weather = "cloud.sun"
    case stocks = "chart.line.uptrend.xyaxis"
    case settings = "gearshape"
    case chat = "bubble.left"
    case close = "xmark"
    case minimize = "minus"
    case lobster = "fish"
}
