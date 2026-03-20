//
//  OpenClawPetApp.swift
//  OpenClawPet
//
//  Main App Entry Point
//

import SwiftUI

@main
struct OpenClawPetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}
