//
//  WindowController.swift
//  OpenClawPet
//
//  Custom window controller for the pet window
//

import AppKit
import SwiftUI

class PetWindowController: NSWindowController {
    
    convenience init() {
        let contentView = ContentView()
        let hostingController = NSHostingController(rootView: contentView)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window.title = "OpenClaw Pet"
        window.contentViewController = hostingController
        window.isMovableByWindowBackground = true
        window.backgroundColor = .clear
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        // Set window level to floating
        window.level = .floating
        
        // Initial position
        window.setFrameOrigin(NSPoint(x: 100, y: 100))
        
        self.init(window: window)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // Additional setup
        window?.isReleasedWhenClosed = false
    }
    
    func showPet() {
        window?.orderFront(nil)
    }
    
    func hidePet() {
        window?.orderOut(nil)
    }
    
    func togglePet() {
        if window?.isVisible == true {
            hidePet()
        } else {
            showPet()
        }
    }
}

// MARK: - App Delegate Extension
extension AppDelegate {
    var petWindowController: PetWindowController? {
        return NSApp.delegate?.windowControllers.first as? PetWindowController
    }
}
