//
//  AppInfo.swift
//  OpenClawPet
//
//  App metadata and configuration
//

import Foundation

enum AppInfo {
    static let name = "OpenClaw Pet"
    static let bundleId = "com.openclaw.pet"
    static let version = "1.0.0"
    static let build = "1"
    
    static let description = "OpenClaw 桌面電子寵物 - 可愛的龍蝦吉祥物"
    static let author = "OpenClaw Team"
    
    // Minimum requirements
    static let minOSVersion = "14.0"  // macOS Sonoma
    
    // URLs
    static let website = "https://openclaw.ai"
    static let supportEmail = "support@openclaw.ai"
}

// MARK: - Feature Flags
enum FeatureFlags {
    static let enableAnimations = true
    static let enableNotifications = true
    static let enableGatewayConnection = true
    static let enableVoiceInput = false  // Requires ElevenLabs
    static let enableCloudSync = false   // Future feature
}
