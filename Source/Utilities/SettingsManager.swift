import Foundation

final class SettingsManager {
    static let shared = SettingsManager()
    
    // MARK: - Connection Settings
    @UserDefaultsBacked(key: "autoConnect", defaultValue: true)
    var autoConnect: Bool
    
    @UserDefaultsBacked(key: "keepAlive", defaultValue: true)
    var keepAlive: Bool
    
    @UserDefaultsBacked(key: "batteryOptimization", defaultValue: true)
    var batteryOptimization: Bool
    
    // MARK: - Network Settings
    @UserDefaultsBacked(key: "mtuSize", defaultValue: 1500)
    var mtuSize: Int
    
    @UserDefaultsBacked(key: "dnsServers", defaultValue: ["8.8.8.8", "8.8.4.4"])
    var dnsServers: [String]
    
    @UserDefaultsBacked(key: "ipv6Enabled", defaultValue: true)
    var ipv6Enabled: Bool
    
    // MARK: - Security Settings
    @UserDefaultsBacked(key: "dataEncryption", defaultValue: true)
    var dataEncryption: Bool
    
    @UserDefaultsBacked(key: "secureDNS", defaultValue: true)
    var secureDNS: Bool
    
    @UserDefaultsBacked(key: "killSwitch", defaultValue: false)
    var killSwitch: Bool
    
    // MARK: - Advanced Settings
    @UserDefaultsBacked(key: "debugMode", defaultValue: false)
    var debugMode: Bool
    
    @UserDefaultsBacked(key: "loggingEnabled", defaultValue: true)
    var loggingEnabled: Bool
    
    private init() {}
    
    func resetToDefaults() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
}

// MARK: - Property Wrapper for UserDefaults
@propertyWrapper
struct UserDefaultsBacked<T> {
    let key: String
    let defaultValue: T
    
    var wrappedValue: T {
        get {
            UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}
