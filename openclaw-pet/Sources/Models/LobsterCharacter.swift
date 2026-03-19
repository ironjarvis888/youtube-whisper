//
//  LobsterCharacter.swift
//  OpenClawPet
//
//  Core lobster character logic and behaviors
//

import Foundation
import SwiftUI
import Combine

class LobsterCharacter: ObservableObject {
    static let shared = LobsterCharacter()
    
    @Published var mood: LobsterMood = .idle
    @Published var position: CGPoint = CGPoint(x: 200, y: 200)
    @Published var isAnimating: Bool = true
    @Published var currentAnimation: AnimationType = .idle
    
    private var animationTimer: Timer?
    private var moveTimer: Timer?
    
    // MARK: - Animation Config
    let animationInterval: TimeInterval = 3.0
    
    private init() {
        startIdleAnimation()
    }
    
    func setup() {
        // Initial setup
        startIdleAnimation()
    }
    
    // MARK: - Animation Control
    
    func startIdleAnimation() {
        stopAllAnimations()
        
        // Random idle animations
        animationTimer = Timer.scheduledTimer(withTimeInterval: animationInterval, repeats: true) { [weak self] _ in
            self?.playRandomIdleAnimation()
        }
        
        // Random movement
        moveTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.moveRandomly()
        }
    }
    
    func stopAllAnimations() {
        animationTimer?.invalidate()
        animationTimer = nil
        moveTimer?.invalidate()
        moveTimer = nil
    }
    
    private func playRandomIdleAnimation() {
        let animations: [LobsterMood] = [.happy, .thinking, .talking]
        if let random = animations.randomElement() {
            withAnimation(.easeInOut(duration: 0.5)) {
                self.mood = random
            }
            
            // Return to idle after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                self?.mood = .idle
            }
        }
    }
    
    private func moveRandomly() {
        guard isAnimating else { return }
        
        let screenWidth: CGFloat = 400
        let screenHeight: CGFloat = 300
        let margin: CGFloat = 50
        
        let newX = CGFloat.random(in: margin...(screenWidth - margin))
        let newY = CGFloat.random(in: margin...(screenHeight - margin))
        
        withAnimation(.easeInOut(duration: 2.0)) {
            self.position = CGPoint(x: newX, y: newY)
        }
    }
    
    // MARK: - Mood Control
    
    func setMood(_ newMood: LobsterMood) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            self.mood = newMood
        }
    }
    
    func say(text: String) {
        setMood(.talking)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.setMood(.idle)
        }
    }
    
    func think() {
        setMood(.thinking)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.setMood(.idle)
        }
    }
    
    func sleep() {
        setMood(.sleeping)
        isAnimating = false
    }
    
    func wake() {
        setMood(.happy)
        isAnimating = true
        startIdleAnimation()
    }
    
    func alert() {
        setMood(.alert)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.setMood(.idle)
        }
    }
}

// MARK: - Animation Types
enum AnimationType: String {
    case idle = "idle"
    case walk = "walk"
    case talk = "talk"
    case sleep = "sleep"
    case happy = "happy"
    case alert = "alert"
}
