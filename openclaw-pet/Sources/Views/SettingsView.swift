//
//  SettingsView.swift
//  OpenClawPet
//
//  Settings panel view
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = UserSettings.shared
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        TabView {
            // 外觀設定
            AppearanceSettingsView()
                .tabItem {
                    Label("外觀", systemImage: "paintbrush")
                }
            
            // 主題設定
            ThemeSettingsView()
                .tabItem {
                    Label("主題", systemImage: "moon.stars")
                }
            
            // 對話設定
            ChatSettingsView()
                .tabItem {
                    Label("對話", systemImage: "bubble.left.and.bubble.right")
                }
            
            // 通知設定
            NotificationSettingsView()
                .tabItem {
                    Label("通知", systemImage: "bell")
                }
        }
        .frame(width: 450, height: 400)
    }
}

struct AppearanceSettingsView: View {
    @ObservedObject var settings = UserSettings.shared
    
    var body: some View {
        Form {
            Section("角色") {
                Picker("角色", selection: $settings.characterColor) {
                    ForEach(CharacterColor.allCases) { color in
                        HStack {
                            Circle()
                                .fill(Color(hex: color.hex))
                                .frame(width: 20, height: 20)
                            Text(color.rawValue)
                        }
                    }
                }
                
                Picker("尺寸", selection: $settings.characterSize) {
                    ForEach(CharacterSize.allCases) { size in
                        Text(size.rawValue)
                    }
                }
                
                Picker("動作風格", selection: $settings.animationStyle) {
                    ForEach(AnimationStyle.allCases) { style in
                        Text(style.rawValue)
                    }
                }
                
                Picker("配件", selection: $settings.currentAccessory) {
                    ForEach(Accessory.allCases) { accessory in
                        Text(accessory.rawValue)
                    }
                }
            }
        }
        .padding()
    }
}

struct ThemeSettingsView: View {
    @ObservedObject var settings = UserSettings.shared
    
    var body: some View {
        Form {
            Section("模式") {
                Picker("主題", selection: $settings.themeMode) {
                    ForEach(ThemeMode.allCases) { mode in
                        Text(mode.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section("主題色") {
                ColorPicker("強調色", selection: $settings.accentColor)
            }
        }
        .padding()
    }
}

struct ChatSettingsView: View {
    @ObservedObject var settings = UserSettings.shared
    
    var body: some View {
        Form {
            Section("對話視窗") {
                Picker("風格", selection: $settings.chatBubbleStyle) {
                    ForEach(ChatBubbleStyle.allCases) { style in
                        Text(style.rawValue)
                    }
                }
                
                Stepper("字體大小: \(Int(settings.fontSize))", value: $settings.fontSize, in: 12...24, step: 2)
            }
        }
        .padding()
    }
}

struct NotificationSettingsView: View {
    @ObservedObject var settings = UserSettings.shared
    
    var body: some View {
        Form {
            Section("提醒") {
                Toggle("天氣提醒", isOn: $settings.weatherAlerts)
                Toggle("股市提醒", isOn: $settings.stockAlerts)
                Toggle("訊息通知", isOn: $settings.messageAlerts)
            }
        }
        .padding()
    }
}

#Preview {
    SettingsView()
}
