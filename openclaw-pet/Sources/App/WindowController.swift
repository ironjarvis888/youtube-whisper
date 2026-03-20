//
//  WindowController.swift
//  OpenClawPet
//
//  Custom panel controller for the pet window - floating desktop pet
//

import AppKit
import SwiftUI

class PetPanelController: NSPanel {
    
    convenience init() {
        // 只有寵物的浮動視窗
        let petView = PetOnlyView()
        let hostingController = NSHostingController(rootView: petView)
        
        self.init(
            contentRect: NSRect(x: 0, y: 0, width: 120, height: 100),
            styleMask: [.nonactivatingPanel, .fullSizeContentView, .borderless],
            backing: .buffered,
            defer: false
        )
        
        self.contentViewController = hostingController
        self.isMovableByWindowBackground = true
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = true
        
        // 浮動在所有視窗上面
        self.level = .floating
        
        // 桌面寵物模式
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
        
        // 初始位置 - 桌面右下角
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let x = screenFrame.maxX - 150
            let y = screenFrame.minY + 50
            self.setFrameOrigin(NSPoint(x: x, y: y))
        }
        
        // 右鍵選單
        self.menu = createContextMenu()
        
        // 不顯示在 Dock
        self.hidesOnDeactivate = false
    }
    
    private func createContextMenu() -> NSMenu {
        let menu = NSMenu()
        
        menu.addItem(withTitle: "開啟對話", action: #selector(showChat), keyEquivalent: "o")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "關閉程式", action: #selector(quitApp), keyEquivalent: "q")
        
        return menu
    }
    
    @objc func showChat() {
        NotificationCenter.default.post(name: .showChat, object: nil)
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

// MARK: - Chat Window Controller
class ChatWindowController: NSWindowController {
    
    convenience init() {
        let contentView = ChatBubbleView()
        let hostingController = NSHostingController(rootView: contentView)
        
        let window = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 450),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        
        window.title = "對話"
        window.contentViewController = hostingController
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.backgroundColor = NSColor.windowBackgroundColor
        window.level = .floating
        window.isMovableByWindowBackground = true
        
        // 位置在寵物旁邊
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let x = screenFrame.maxX - 350
            let y = screenFrame.midY
            window.setFrameOrigin(NSPoint(x: x, y: y))
        }
        
        self.init(window: window)
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var petPanel: PetPanelController?
    var chatWindow: ChatWindowController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 啟動浮動寵物模式
        petPanel = PetPanelController()
        petPanel?.orderFront(nil)
        
        // 監聽顯示對話事件
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showChatWindow),
            name: .showChat,
            object: nil
        )
        
        // 設定主選單
        setupMainMenu()
    }
    
    @objc func showChatWindow() {
        if chatWindow == nil {
            chatWindow = ChatWindowController()
        }
        chatWindow?.showWindow(nil)
    }
    
    private func setupMainMenu() {
        let mainMenu = NSMenu()
        
        // App 選單
        let appMenuItem = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "關於 OpenClaw Pet", action: #selector(showAbout), keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "設定...", action: #selector(showSettings), keyEquivalent: ",")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "離開", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenuItem.submenu = appMenu
        mainMenu.addItem(appMenuItem)
        
        NSApplication.shared.mainMenu = mainMenu
    }
    
    @objc func showSettings() {
        // 顯示設定
    }
    
    @objc func showAbout() {
        NSApp.orderFrontStandardAboutPanel(nil)
    }
}
