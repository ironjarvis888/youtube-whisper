//
//  NotificationManager.swift
//  OpenClawPet
//
//  Local notifications for weather, stocks, etc.
//

import Foundation
import UserNotifications
import SwiftUI

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized: Bool = false
    
    private init() {
        checkAuthorization()
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isAuthorized = granted
                if let error = error {
                    print("Notification authorization error: \(error)")
                }
            }
        }
    }
    
    private func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Notifications
    
    func sendNotification(title: String, body: String, identifier: String = UUID().uuidString) {
        guard isAuthorized else {
            print("Notifications not authorized")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }
    
    // MARK: - Quick Notifications
    
    func notifyWeather(temperature: Int, condition: String) {
        sendNotification(
            title: "🌤️ 天氣報告",
            body: "台北現在 \(temperature)°C，\(condition)"
        )
    }
    
    func notifyStock(symbol: String, change: Double) {
        let emoji = change >= 0 ? "📈" : "📉"
        sendNotification(
            title: "📊 股價變動",
            body: "\(symbol) \(emoji) \(String(format: "%.2f", change))%"
        )
    }
    
    func notifyMessage(from: String, preview: String) {
        sendNotification(
            title: "💬 新訊息 from \(from)",
            body: preview
        )
    }
    
    func notifyLobster(message: String) {
        sendNotification(
            title: "🦞 OpenClaw 說",
            body: message
        )
    }
}
