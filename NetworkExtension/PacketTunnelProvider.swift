import NetworkExtension
import Network

class PacketTunnelProvider: NEPacketTunnelProvider {
    private var tunnel: PacketTunnel?
    private let metricManager = MetricsManager.shared
    private var startCompletionHandler: ((Error?) -> Void)?
    private var stopCompletionHandler: (() -> Void)?
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        startCompletionHandler = completionHandler
        
        // Setup network settings
        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "192.168.1.1")
        
        // Configure IPv4
        let ipv4Settings = NEIPv4Settings(addresses: ["192.168.1.2"], subnetMasks: ["255.255.255.0"])
        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        networkSettings.ipv4Settings = ipv4Settings
        
        // Configure IPv6
        let ipv6Settings = NEIPv6Settings(addresses: ["fd00::2"], networkPrefixLengths: [64])
        ipv6Settings.includedRoutes = [NEIPv6Route.default()]
        networkSettings.ipv6Settings = ipv6Settings
        
        // Configure DNS
        networkSettings.dnsSettings = NEDNSSettings(servers: ["8.8.8.8", "8.8.4.4"])
        networkSettings.mtu = 1500
        
        setTunnelNetworkSettings(networkSettings) { [weak self] error in
            if let error = error {
                self?.startCompletionHandler?(error)
                return
            }
            
            self?.tunnel = PacketTunnel(packetFlow: self?.packetFlow ?? self!.packetFlow)
            self?.tunnel?.startTunnel()
            self?.startPacketForwarding()
            self?.startCompletionHandler?(nil)
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        stopCompletionHandler = completionHandler
        tunnel?.stopTunnel()
        
        // Clean up resources
        tunnel = nil
        stopCompletionHandler?()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Handle messages from the container app
        guard let message = try? JSONDecoder().decode(TunnelMessage.self, from: messageData) else {
            completionHandler?(nil)
            return
        }
        
        switch message.type {
        case .statusRequest:
            let status = TunnelStatus(isConnected: tunnel != nil)
            let responseData = try? JSONEncoder().encode(status)
            completionHandler?(responseData)
            
        case .metricsRequest:
            let metrics = metricManager.currentMetrics
            let responseData = try? JSONEncoder().encode(metrics)
            completionHandler?(responseData)
            
        default:
            completionHandler?(nil)
        }
    }
    
    private func startPacketForwarding() {
        packetFlow.readPackets { [weak self] packets, protocols in
            self?.processPackets(packets, protocols: protocols)
        }
    }
    
    private func processPackets(_ packets: [Data], protocols: [NSNumber]) {
        // Process and forward packets
        for (packet, protocolNumber) in zip(packets, protocols) {
            if let modifiedPacket = tunnel?.processPacket(packet, protocolNumber: protocolNumber) {
                packetFlow.writePackets([modifiedPacket], withProtocols: [protocolNumber])
            }
        }
    }
}

// MARK: - Tunnel Communication
struct TunnelMessage: Codable {
    enum MessageType: String, Codable {
        case statusRequest
        case metricsRequest
        case configurationUpdate
    }
    
    let type: MessageType
    let payload: Data?
}

struct TunnelStatus: Codable {
    let isConnected: Bool
    let timestamp: Date = Date()
}
