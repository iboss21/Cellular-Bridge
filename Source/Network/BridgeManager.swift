import NetworkExtension
import Network

final class BridgeManager {
    static let shared = BridgeManager()
    
    private var providerManager: NETunnelProviderManager?
    private var connection: NETunnelProviderSession?
    private let securityProvider = SecurityProvider()
    
    // Connection status
    private(set) var isConnected: Bool = false {
        didSet {
            NotificationCenter.default.post(name: .bridgeConnectionStatusChanged, object: nil)
        }
    }
    
    func initialize() {
        loadProviderManager()
        setupNotifications()
    }
    
    func startBridge(completion: @escaping (Error?) -> Void) {
        guard let connection = connection else {
            completion(NSError(domain: "com.cellularbridge", code: -1, userInfo: [NSLocalizedDescriptionKey: "Connection not initialized"]))
            return
        }
        
        do {
            try connection.startVPNTunnel()
            isConnected = true
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func stopBridge(completion: @escaping (Error?) -> Void) {
        connection?.stopVPNTunnel()
        isConnected = false
        completion(nil)
    }
    
    private func loadProviderManager() {
        NETunnelProviderManager.loadAllFromPreferences { [weak self] managers, error in
            if let error = error {
                print("Error loading preferences: \(error)")
                return
            }
            
            let manager: NETunnelProviderManager
            if let existingManager = managers?.first {
                manager = existingManager
            } else {
                manager = NETunnelProviderManager()
                self?.configureProvider(manager)
            }
            
            self?.providerManager = manager
            self?.connection = manager.connection as? NETunnelProviderSession
        }
    }
    
    private func configureProvider(_ manager: NETunnelProviderManager) {
        let tunnelProtocol = NETunnelProviderProtocol()
        tunnelProtocol.providerBundleIdentifier = "com.yourcompany.CellularBridge.PacketTunnelProvider"
        tunnelProtocol.serverAddress = "Cellular Bridge"
        
        manager.protocolConfiguration = tunnelProtocol
        manager.localizedDescription = "Cellular Bridge"
        manager.isEnabled = true
        
        manager.saveToPreferences { error in
            if let error = error {
                print("Error saving preferences: \(error)")
            }
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(vpnStatusChanged(_:)),
            name: .NEVPNStatusDidChange,
            object: nil
        )
    }
    
    @objc private func vpnStatusChanged(_ notification: Notification) {
        guard let connection = notification.object as? NEVPNConnection else { return }
        isConnected = connection.status == .connected
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let bridgeConnectionStatusChanged = Notification.Name("bridgeConnectionStatusChanged")
}
