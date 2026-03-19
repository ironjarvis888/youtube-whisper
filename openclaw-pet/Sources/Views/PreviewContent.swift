//
//  Preview Content.swift
//  OpenClawPet
//
//  Preview content for Xcode Canvas
//

import SwiftUI

struct PreviewContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Preview 1: Lobster Character
            LobsterCharacterView()
                .frame(width: 150, height: 150)
                .background(Color.gray.opacity(0.1))
                .previewDisplayName("龍蝦角色")
            
            // Preview 2: Chat Bubble
            ChatBubbleView()
                .frame(width: 320, height: 400)
                .previewDisplayName("對話氣泡")
            
            // Preview 3: Settings
            SettingsView()
                .frame(width: 450, height: 400)
                .previewDisplayName("設定面板")
            
            // Preview 4: Toolbar
            ToolbarView()
                .previewDisplayName("工具列")
        }
    }
}

#Preview("所有元件") {
    PreviewContentView()
}

#Preview("龍蝦角色") {
    LobsterCharacterView()
        .frame(width: 200, height: 200)
}

#Preview("對話氣泡") {
    ChatBubbleView()
        .frame(width: 320, height: 400)
}

#Preview("設定") {
    SettingsView()
        .frame(width: 450, height: 400)
}

#Preview("工具列") {
    ToolbarView()
        .padding()
}
