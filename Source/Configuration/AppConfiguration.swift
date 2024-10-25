import Foundation

// MARK: - App Configuration
final class AppConfiguration {
    static let shared = AppConfiguration()
    
    // App Settings
    private(set) var environment: Environment
    private(set) var configuration: Configuration
    private let configurationManager = ConfigurationManager()
    
    // Feature Flags
    var isDebugEnabled: Bool {
        get { configuration.debugMode }
        set { updateConfiguration(\.debugMode, newValue) }
    }
    
    private init() {
        #if DEBUG
        self.environment = .development
        #else
        self.environment = .production
        #endif
        
        self.configuration = ConfigurationManager.loadDefaultConfiguration()
        setupConfiguration()
    }
    
    func configure(with options: ConfigurationOptions) {
        configuration = configurationManager.buildConfiguration(with: options)
        applyConfiguration()
    }
    
    private func setupConfiguration() {
        setupLogging()
        setupNetworking()
        setupSecurity()
        setupAnalytics()
    }
    
    private func applyConfiguration() {
        // Apply configuration changes
        NotificationCenter.default.post(name: .configurationDidUpdate, object: nil)
    }
    
    private func updateConfiguration<T>(_ keyPath: WritableKeyPath<Configuration, T>, _ value: T) {
        var updatedConfig = configuration
        updatedConfig[keyPath: keyPath] = value
        configuration = updatedConfig
        applyConfiguration()
    }
}

// MARK: - Configuration Types
enum Environment {
    case development
    case staging
    case production
    
    var baseURL: URL {
        switch self {
        case .development:
            return URL(string: "https://dev-api.cellularbridge.com")!
        case .staging:
            return URL(string: "https://staging-api.cellularbridge.com")!
        case .production:
            return URL(string: "https://api.cellularbridge.com")!
        }
    }
}

struct Configuration: Codable {
    var debugMode: Bool
    var analyticsEnabled: Bool
    var encryptionEnabled: Bool
    var networkConfig: NetworkConfig
    var securityConfig: SecurityConfig
    var analyticsConfig: AnalyticsConfig
    
    struct NetworkConfig: Codable {
        var maxConnections: Int
        var timeout: TimeInterval
        var retryCount: Int
        var qosEnabled: Bool
    }
    
    struct SecurityConfig: Codable {
        var encryptionLevel: EncryptionLevel
        var certificateValidation: Bool
        var biometricAuthEnabled: Bool
    }
    
    struct AnalyticsConfig: Codable {
        var sessionTracking: Bool
        var crashReporting: Bool
        var performanceMonitoring: Bool
    }
}

struct ConfigurationOptions {
    let environment: Environment
    let debugMode: Bool
    let analyticsEnabled: Bool
    let encryptionEnabled: Bool
    let networkOptions: NetworkOptions
    let securityOptions: SecurityOptions
    let analyticsOptions: AnalyticsOptions
    
    struct NetworkOptions {
        let maxConnections: Int
        let timeout: TimeInterval
        let retryCount: Int
        let qosEnabled: Bool
    }
    
    struct SecurityOptions {
        let encryptionLevel: EncryptionLevel
        let certificateValidation: Bool
        let biometricAuthEnabled: Bool
    }
    
    struct AnalyticsOptions {
        let sessionTracking: Bool
        let crashReporting: Bool
        let performanceMonitoring: Bool
    }
}

enum EncryptionLevel {
    case none
    case standard
    case high
}

// MARK: - Configuration Manager
final class ConfigurationManager {
    static func loadDefaultConfiguration() -> Configuration {
        return Configuration(
            debugMode: false,
            analyticsEnabled: true,
            encryptionEnabled: true,
            networkConfig: Configuration.NetworkConfig(
                maxConnections: 5,
                timeout: 30,
                retryCount: 3,
                qosEnabled: true
            ),
            securityConfig: Configuration.SecurityConfig(
                encryptionLevel: .high,
                certificateValidation: true,
                biometricAuthEnabled: true
            ),
            analyticsConfig: Configuration.AnalyticsConfig(
                sessionTracking: true,
                crashReporting: true,
                performanceMonitoring: true
            )
        )
    }
    
    func buildConfiguration(with options: ConfigurationOptions) -> Configuration {
        return Configuration(
            debugMode: options.debugMode,
            analyticsEnabled: options.analyticsEnabled,
            encryptionEnabled: options.encryptionEnabled,
            networkConfig: Configuration.NetworkConfig(
                maxConnections: options.networkOptions.maxConnections,
                timeout: options.networkOptions.timeout,
                retryCount: options.networkOptions.retryCount,
                qosEnabled: options.networkOptions.qosEnabled
            ),
            securityConfig: Configuration.SecurityConfig(
                encryptionLevel: options.securityOptions.encryptionLevel,
                certificateValidation: options.securityOptions.certificateValidation,
                biometricAuthEnabled: options.securityOptions.biometricAuthEnabled
            ),
            analyticsConfig: Configuration.AnalyticsConfig(
                sessionTracking: options.analyticsOptions.sessionTracking,
                crashReporting: options.analyticsOptions.crashReporting,
                performanceMonitoring: options.analyticsOptions.performanceMonitoring
            )
        )
    }
}

// MARK: - Extensions
extension Notification.Name {
    static let configurationDidUpdate = Notification.Name("configurationDidUpdate")
}
