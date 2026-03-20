//
//  PetOnlyView.swift
//  OpenClawPet
//
//  Pet view with right-click menu
//

import SwiftUI

struct PetOnlyView: View {
    @StateObject private var state = LobsterState.shared
    @ObservedObject var settings = UserSettings.shared
    
    var body: some View {
        ZStack {
            // 根據選擇顯示寵物
            switch settings.petType {
            case .lobster:
                LobsterCharacterView()
                    .scaleEffect(0.8)
            case .dog:
                DogCharacterView()
                    .scaleEffect(0.8)
            case .cat:
                CatCharacterView()
                    .scaleEffect(0.8)
            }
        }
        .frame(width: 120, height: 100)
        .contextMenu {
            Button("開啟對話") {
                NotificationCenter.default.post(name: .showChat, object: nil)
            }
            Divider()
            Button("切換寵物") {
                // 選擇下一個寵物
                let allPets = PetType.allCases
                if let currentIndex = allPets.firstIndex(of: settings.petType) {
                    let nextIndex = (currentIndex + 1) % allPets.count
                    settings.petType = allPets[nextIndex]
                }
            }
            Divider()
            Button("關閉程式", role: .destructive) {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}
