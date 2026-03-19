# OpenClaw Pet

Mac 桌面電子寵物 App - OpenClaw 吉祥物

## 專案狀態

🚧 開發中 (v0.1.0)

## 專案結構

```
openclaw-pet/
├── Sources/
│   ├── App/              # App 入口與生命週期
│   │   ├── OpenClawPetApp.swift
│   │   ├── AppDelegate.swift
│   │   └── WindowController.swift
│   ├── Models/           # 資料模型
│   │   ├── Models.swift
│   │   ├── LobsterState.swift
│   │   ├── LobsterCharacter.swift
│   │   └── UserSettings.swift
│   ├── Views/            # SwiftUI 視圖
│   │   ├── ContentView.swift
│   │   ├── LobsterCharacterView.swift
│   │   ├── ChatBubbleView.swift
│   │   ├── SettingsView.swift
│   │   └── ToolbarView.swift
│   └── Services/         # 服務層
│       ├── OpenClawGateway.swift
│       ├── NotificationManager.swift
│       └── PreferencesManager.swift
├── Resources/             # 圖片、動畫資源
├── Tests/                # 測試
└── docs/                # 規劃文件
```

## 功能清單

| 功能 | 狀態 |
|------|------|
| 龍蝦角色顯示 | ✅ |
| 角色動畫 (idle/talking/sleeping) | ✅ |
| 顏色自訂 (紅/藍/綠/紫/粉) | ✅ |
| 尺寸調整 (小/中/大) | ✅ |
| 對話氣泡 | ✅ |
| 工具列 (天氣/股市/設定) | ✅ |
| 設定面板 | ✅ |
| 通知系統 | ✅ |
| Gateway 通訊 | 🔄 |
| 偏好儲存 | ✅ |

## 技術堆疊

- SwiftUI
- SpriteKit (動畫)
- Xcode
- URLSession (WebSocket)

## 相關文件

- [OpenClaw-Pet-規劃.md](./docs/OpenClaw-Pet-規劃.md)
- [UI-設計規格.md](./docs/UI-設計規格.md)
