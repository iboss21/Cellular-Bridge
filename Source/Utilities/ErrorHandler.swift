import Foundation

enum BridgeError: LocalizedError {
    case connectionFailed(String)
    case tunnelSetupFailed(String)
    case networkUnavailable
    case permissionDenied
    case configurationInvalid(String)
    case securityError(String)
    case systemError(String)
    
    var errorDescription: String? {
        switch self {
        case .connectionFailed(let reason):
            return "Connection failed: \(reason)"
        case .tunnelSetupFailed(let reason):
            return "Tunnel setup failed: \(reason)"
        case .networkUnavailable:
            return "Network is unavailable"
        case .permissionDenied:
            return "Permission denied"
        case .configurationInvalid(let reason):
            return "Invalid configuration: \(reason)"
        case .securityError(let reason):
            return "Security error: \(reason)"
        case .systemError(let reason):
            return "System error: \(reason)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .connectionFailed:
            return "Please check your network connection and try again."
        case .tunnelSetupFailed:
            return "Try restarting the application or check system settings."
        case .networkUnavailable:
            return "Please ensure you have an active network connection."
        case .permissionDenied:
            return "Please grant the necessary permissions in Settings."
        case .configurationInvalid:
            return "Please check your configuration settings."
        case .securityError:
            return "Please verify security settings and try again."
        case .systemError:
            return "Please restart the application or contact support."
        }
    }
}

final class ErrorHandler {
    static let shared = ErrorHandler()
    
    private init() {}
    
    func handle(_ error: Error, file: String = #file, line: Int = #line) {
        // Log error
        Logger.shared.log(
            "Error occurred: \(error.localizedDescription)",
            type: .error,
            file: file,
            line: line
        )
        
        // Handle specific error types
        if let bridgeError = error as? BridgeError {
            handleBridgeError(bridgeError)
        } else {
            handleGenericError(error)
        }
        
        // Notify observers
        NotificationCenter.default.post(
            name: .errorOccurred,
            object: error
        )
    }
    
    private func handleBridgeError(_ error: BridgeError) {
        switch error {
        case .connectionFailed:
            attemptReconnection()
        case .tunnelSetupFailed:
            resetTunnelConfiguration()
        case .networkUnavailable:
            startNetworkMonitoring()
        case .permissionDenied:
            promptForPermissions()
        case .configurationInvalid:
            resetToDefaultConfiguration()
        case .securityError:
            handleSecurityIssue()
        case .systemError:
            performSystemReset()
        }
    }
    
    private func handleGenericError(_ error: Error) {
        // Handle unknown errors
        Logger.shared.log("Unhandled error: \(error)", type: .error)
    }
    
    // MARK: - Error Recovery Methods
    
    private func attemptReconnection() {
        BridgeManager.shared.stopBridge { [weak self] in
            self?.startReconnectionTimer()
        }
    }
    
    private func resetTunnelConfiguration() {
        // Reset tunnel configuration
        SettingsManager.shared.resetToDefaults()
    }
    
    private func startNetworkMonitoring() {
        NetworkMonitor.shared.startMonitoring()
    }
    
    private func promptForPermissions() {
        // Request necessary permissions
    }
    
    private func resetToDefaultConfiguration() {
        SettingsManager.shared.resetToDefaults()
    }
    
    private func handleSecurityIssue() {
        // Handle security-related issues
    }
    
    private func performSystemReset() {
        // Perform complete system reset
    }
    
    private func startReconnectionTimer() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            BridgeManager.shared.startBridge { error in
                if let error = error {
                    Logger.shared.log("Reconnection failed: \(error)", type: .error)
                }
            }
        }
    }
}

extension Notification.Name {
    static let errorOccurred = Notification.Name("errorOccurred")
}
