//
//  MenuBarController.swift
//  OpenClawPet
//
//  Menu bar controller with close/quit option
//

import AppKit
import SwiftUI

class MenuBarController {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    
    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "fish", accessibilityDescription: "OpenClaw Pet")
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 220, height: 180)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: MenuBarView())
    }
    
    @objc private func togglePopover() {
        guard let button = statusItem?.button, let popover = popover else { return }
        
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}

struct MenuBarView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("🦞 OpenClaw Pet")
                    .font(.headline)
                Spacer()
            }
            .padding(.bottom, 4)
            
            Divider()
            
            // Actions
            Button(action: { 
                NotificationCenter.default.post(name: .showChat, object: nil)
                closePopover()
            }) {
                Label("開啟對話", systemImage: "bubble.left")
            }
            .buttonStyle(.plain)
            
            Divider()
            
            // Status
            HStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 8, height: 8)
                Text("線上")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // Close/Quit
            Button(action: { 
                NSApplication.shared.terminate(nil)
            }) {
                Label("關閉程式", systemImage: "xmark.circle")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .frame(width: 200)
    }
    
    private func closePopover() {
        NSApp.sendAction(#selector(NSPopover.performClose(_:)), to: nil, from: nil)
    }
}

extension Notification.Name {
    static let showChat = Notification.Name("showChat")
    static let quitApp = Notification.Name("quitApp")
}
