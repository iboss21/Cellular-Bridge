import Foundation
import CryptoKit
import Security

final class SecurityManager {
    static let shared = SecurityManager()
    
    private let keychain = KeychainManager()
    private let cryptoProvider = CryptoProvider()
    private let certificateManager = CertificateManager()
    
    // Security Settings
    private(set) var securityLevel: SecurityLevel = .high
    private(set) var encryptionEnabled = true
    private(set) var certificateValidation = true
    
    private init() {
        setupSecurity()
    }
    
    func setupSecurity() {
        // Initialize security components
        initializeEncryption()
        validateCertificates()
        setupSecureConnection()
    }
    
    func processSecurityEvent(_ event: AnalyticEvent) {
        switch event.name {
        case "security_breach_detected":
            handleSecurityBreach(event)
        case "certificate_expired":
            handleCertificateExpiration(event)
        case "encryption_failed":
            handleEncryptionFailure(event)
        default:
            Logger.shared.log("Unknown security event: \(event.name)", type: .warning)
        }
    }
    
    func encryptData(_ data: Data) throws -> Data {
        guard encryptionEnabled else { return data }
        return try cryptoProvider.encrypt(data)
    }
    
    func decryptData(_ data: Data) throws -> Data {
        guard encryptionEnabled else { return data }
        return try cryptoProvider.decrypt(data)
    }
    
    func validateCertificate(_ certificate: SecCertificate) -> Bool {
        guard certificateValidation else { return true }
        return certificateManager.validate(certificate)
    }
    
    private func initializeEncryption() {
        do {
            try cryptoProvider.initialize()
        } catch {
            Logger.shared.log("Encryption initialization failed: \(error)", type: .error)
            handleEncryptionFailure()
        }
    }
    
    private func validateCertificates() {
        certificateManager.validateAll { result in
            switch result {
            case .success:
                Logger.shared.log("Certificate validation successful", type: .info)
            case .failure(let error):
                Logger.shared.log("Certificate validation failed: \(error)", type: .error)
                self.handleCertificateValidationFailure(error)
            }
        }
    }
    
    private func setupSecureConnection() {
        // Setup secure connection configuration
    }
    
    private func handleSecurityBreach(_ event: AnalyticEvent) {
        // Handle security breach
        NotificationCenter.default.post(
            name: .securityBreachDetected,
            object: event
        )
    }
    
    private func handleCertificateExpiration(_ event: AnalyticEvent) {
        // Handle certificate expiration
        certificateManager.renewCertificates()
    }
    
    private func handleEncryptionFailure(_ event: AnalyticEvent? = nil) {
        // Handle encryption failure
        encryptionEnabled = false
        NotificationCenter.default.post(
            name: .encryptionFailed,
            object: event
        )
    }
    
    private func handleCertificateValidationFailure(_ error: Error) {
        // Handle certificate validation failure
        certificateValidation = false
        NotificationCenter.default.post(
            name: .certificateValidationFailed,
            object: error
        )
    }
}

// MARK: - Security Types
enum SecurityLevel {
    case low
    case medium
    case high
    
    var requiresEncryption: Bool {
        switch self {
        case .low: return false
        case .medium, .high: return true
        }
    }
    
    var requiresCertificateValidation: Bool {
        switch self {
        case .low, .medium: return false
        case .high: return true
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let securityBreachDetected = Notification.Name("securityBreachDetected")
    static let encryptionFailed = Notification.Name("encryptionFailed")
    static let certificateValidationFailed = Notification.Name("certificateValidationFailed")
}
