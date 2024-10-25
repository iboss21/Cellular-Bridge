import Foundation
import os.log

final class Logger {
    static let shared = Logger()
    
    private let osLog: OSLog
    private let dateFormatter: DateFormatter
    private let fileManager: FileManager
    private let logFileURL: URL
    
    private init() {
        self.osLog = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "CellularBridge")
        
        self.dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        
        self.fileManager = FileManager.default
        
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.logFileURL = documentsPath.appendingPathComponent("cellular_bridge.log")
        
        createLogFileIfNeeded()
    }
    
    func log(_ message: String, type: LogType = .info, file: String = #file, function: String = #function, line: Int = #line) {
        guard SettingsManager.shared.loggingEnabled else { return }
        
        let timestamp = dateFormatter.string(from: Date())
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "\(timestamp) [\(type.rawValue)] [\(fileName):\(line)] \(function): \(message)"
        
        // Log to console
        os_log("%{public}@", log: osLog, type: type.osLogType, logMessage)
        
        // Log to file
        appendToLogFile(logMessage)
    }
    
    func clearLogs() {
        try? fileManager.removeItem(at: logFileURL)
        createLogFileIfNeeded()
    }
    
    func getLogs() -> String {
        (try? String(contentsOf: logFileURL, encoding: .utf8)) ?? ""
    }
    
    private func createLogFileIfNeeded() {
        guard !fileManager.fileExists(atPath: logFileURL.path) else { return }
        fileManager.createFile(atPath: logFileURL.path, contents: nil)
    }
    
    private func appendToLogFile(_ message: String) {
        guard let data = (message + "\n").data(using: .utf8) else { return }
        
        if let fileHandle = try? FileHandle(forWritingTo: logFileURL) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
            try? fileHandle.close()
        }
    }
}

// MARK: - Log Types
enum LogType: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warning = "WARNING"
    case error = "ERROR"
    
    var osLogType: OSLogType {
        switch self {
        case .debug: return .debug
        case .info: return .info
        case .warning: return .error
        case .error: return .fault
        }
    }
}

// Usage Example:
/*
Logger.shared.log("Connection established", type: .info)
Logger.shared.log("Data transfer failed", type: .error)
*/
