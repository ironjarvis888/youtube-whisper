//
//  AppDelegate.swift
//  OpenClawPet
//
//  App Delegate for lifecycle management
//

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var popover: NSPopover?
    var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 設定主選單
        setupMainMenu()
        
        // 初始化龍蝦角色
        LobsterCharacter.shared.setup()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // 儲存使用者設定
        UserSettings.shared.save()
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
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
    
    @objc func showAbout() {
        NSApp.orderFrontStandardAboutPanel(nil)
    }
}
