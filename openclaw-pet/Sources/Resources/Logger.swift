//
//  Logger.swift
//  OpenClawPet
//
//  Logging utility for debugging
//

import Foundation
import os.log

class Logger {
    static let shared = Logger()
    
    private let logger: os.Logger
    private let dateFormatter: DateFormatter
    
    private init() {
        logger = os.Logger(subsystem: "com.openclaw.pet", category: "general")
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    // MARK: - Log Levels
    
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        logger.debug("[\(fileName):\(line)] \(function) - \(message)")
        print("🟢 [DEBUG] \(dateFormatter.string(from: Date())) - \(message)")
        #endif
    }
    
    func info(_ message: String) {
        logger.info("\(message)")
        print("🔵 [INFO] \(dateFormatter.string(from: Date())) - \(message)")
    }
    
    func warning(_ message: String) {
        logger.warning("\(message)")
        print("🟡 [WARNING] \(dateFormatter.string(from: Date())) - \(message)")
    }
    
    func error(_ message: String, error: Error? = nil) {
        logger.error("\(message)")
        if let error = error {
            print("🔴 [ERROR] \(dateFormatter.string(from: Date())) - \(message): \(error.localizedDescription)")
        } else {
            print("🔴 [ERROR] \(dateFormatter.string(from: Date())) - \(message)")
        }
    }
    
    // MARK: - Convenience
    
    func logEvent(_ event: String, properties: [String: Any]? = nil) {
        var message = "📱 \(event)"
        if let properties = properties {
            let propsString = properties.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
            message += " | \(propsString)"
        }
        info(message)
    }
}
