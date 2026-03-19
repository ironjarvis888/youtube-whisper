//
//  LobsterState.swift
//  OpenClawPet
//
//  Observable state for the lobster character
//

import Foundation
import SwiftUI

class LobsterState: ObservableObject {
    static let shared = LobsterState()
    
    @Published var position: CGPoint = CGPoint(x: 200, y: 200)
    @Published var mood: LobsterMood = .idle
    @Published var isMoving: Bool = false
    
    private init() {}
    
    func setMood(_ newMood: LobsterMood) {
        withAnimation(.easeInOut(duration: 0.3)) {
            self.mood = newMood
        }
    }
    
    func moveTo(_ newPosition: CGPoint) {
        withAnimation(.easeInOut(duration: 0.5)) {
            self.position = newPosition
        }
    }
}

// MARK: - Idle mood for initial state
extension LobsterMood {
    static var idle: LobsterMood { .happy }
}
