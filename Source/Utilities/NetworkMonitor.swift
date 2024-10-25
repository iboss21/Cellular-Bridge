import Network
import Foundation

final class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "com.cellularbridge.networkmonitor")
    
    private(set) var isConnected = false
    private(set) var connectionType: ConnectionType = .unknown
    private(set) var availableInterfaces: [NetworkInterface] = []
    
    private init() {
        monitor = NWPathMonitor()
        setupMonitor()
    }
    
    private func setupMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.updateNetworkStatus(path)
        }
        monitor.start(queue: queue)
    }
    
    private func updateNetworkStatus(_ path: NWPath) {
        isConnected = path.status == .satisfied
        availableInterfaces = path.availableInterfaces.map { interface in
            NetworkInterface(
                name: interface.name,
                type: interface.type,
                isCellular: interface.type == .cellular
            )
        }
        
        // Determine connection type
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
        
        // Notify observers
        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .networkStatusChanged,
                object: nil
            )
        }
    }
    
    func startMonitoring() {
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}

// MARK: - Supporting Types
enum ConnectionType {
    case wifi
    case cellular
    case ethernet
    case unknown
    
    var description: String {
        switch self {
        case .wifi: return "WiFi"
        case .cellular: return "Cellular"
        case .ethernet: return "Ethernet"
        case .unknown: return "Unknown"
        }
    }
}

struct NetworkInterface {
    let name: String
    let type: NWInterface.InterfaceType
    let isCellular: Bool
}

extension Notification.Name {
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
}
