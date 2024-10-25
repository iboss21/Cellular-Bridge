import Foundation

// MARK: - Connection Models
struct ConnectionState: Codable {
    let id: UUID
    let status: ConnectionStatus
    let timestamp: Date
    let metrics: ConnectionMetrics
    let settings: ConnectionSettings
    
    struct ConnectionMetrics: Codable {
        let uploadSpeed: Double
        let downloadSpeed: Double
        let latency: Double
        let packetLoss: Double
        let connectedDevices: Int
        let uptime: TimeInterval
    }
    
    struct ConnectionSettings: Codable {
        let protocol: ConnectionProtocol
        let encryption: EncryptionType
        let mtu: Int
        let dns: [String]
        let ipv6Enabled: Bool
        
        enum ConnectionProtocol: String, Codable {
            case udp, tcp, adaptive
        }
        
        enum EncryptionType: String, Codable {
            case aes256, chacha20, quantum
        }
    }
}

// MARK: - Device Models
struct ConnectedDevice: Codable, Identifiable {
    let id: UUID
    let name: String
    let ipAddress: String
    let macAddress: String
    let connectionType: DeviceConnectionType
    let connectionTime: Date
    let bandwidth: BandwidthUsage
    
    enum DeviceConnectionType: String, Codable {
        case wifi
        case bluetooth
        case cellular
        case ethernet
    }
    
    struct BandwidthUsage: Codable {
        let upload: Double
        let download: Double
        let limit: Double?
        let priority: Priority
        
        enum Priority: Int, Codable {
            case low = 0
            case medium = 1
            case high = 2
        }
    }
}

// MARK: - Performance Models
struct PerformanceMetrics: Codable {
    let timestamp: Date
    let cpu: CPUMetrics
    let memory: MemoryMetrics
    let network: NetworkMetrics
    let battery: BatteryMetrics
    
    struct CPUMetrics: Codable {
        let usage: Double
        let temperature: Double
        let cores: Int
    }
    
    struct MemoryMetrics: Codable {
        let used: UInt64
        let available: UInt64
        let total: UInt64
    }
    
    struct NetworkMetrics: Codable {
        let bytesIn: UInt64
        let bytesOut: UInt64
        let packetsIn: UInt64
        let packetsOut: UInt64
        let errors: UInt64
    }
    
    struct BatteryMetrics: Codable {
        let level: Double
        let isCharging: Bool
        let temperature: Double
    }
}

// MARK: - Security Models
struct SecurityState: Codable {
    let encryptionStatus: EncryptionStatus
    let certificateStatus: CertificateStatus
    let threats: [SecurityThreat]
    let lastScan: Date
    
    struct EncryptionStatus: Codable {
        let isEnabled: Bool
        let algorithm: String
        let keySize: Int
        let lastRotated: Date
    }
    
    struct CertificateStatus: Codable {
        let isValid: Bool
        let expirationDate: Date
        let issuer: String
        let fingerprint: String
    }
    
    struct SecurityThreat: Codable {
        let id: UUID
        let type: ThreatType
        let severity: Severity
        let timestamp: Date
        let description: String
        let recommendation: String
        
        enum ThreatType: String, Codable {
            case maliciousPacket
            case unauthorizedAccess
            case dataLeak
            case mitm
        }
        
        enum Severity: String, Codable {
            case low, medium, high, critical
        }
    }
}

// MARK: - Analytics Models
struct AnalyticsData: Codable {
    let sessionId: UUID
    let startTime: Date
    let duration: TimeInterval
    let events: [AnalyticEvent]
    let performance: [PerformanceMetric]
    let errors: [ErrorEvent]
    
    struct PerformanceMetric: Codable {
        let timestamp: Date
        let type: MetricType
        let value: Double
        
        enum MetricType: String, Codable {
            case latency
            case throughput
            case packetLoss
            case jitter
        }
    }
    
    struct ErrorEvent: Codable {
        let timestamp: Date
        let code: String
        let message: String
        let stackTrace: String?
        let severity: Severity
        
        enum Severity: String, Codable {
            case info, warning, error, fatal
        }
    }
}

// MARK: - Configuration Models
struct BridgeConfiguration: Codable {
    let general: GeneralConfig
    let network: NetworkConfig
    let security: SecurityConfig
    let performance: PerformanceConfig
    
    struct GeneralConfig: Codable {
        let autoStart: Bool
        let keepAlive: Bool
        let notification: NotificationPreferences
    }
    
    struct NetworkConfig: Codable {
        let protocol: String
        let mtu: Int
        let dns: [String]
        let routing: RoutingConfig
    }
    
    struct SecurityConfig: Codable {
        let encryption: EncryptionConfig
        let certificates: CertificateConfig
        let firewallRules: [FirewallRule]
    }
    
    struct PerformanceConfig: Codable {
        let qos: QoSConfig
        let optimization: OptimizationConfig
        let monitoring: MonitoringConfig
    }
}

// MARK: - Supporting Types
extension BridgeConfiguration {
    struct NotificationPreferences: Codable {
        let enabled: Bool
        let types: Set<NotificationType>
        
        enum NotificationType: String, Codable {
            case connectionStatus
            case performance
            case security
            case errors
        }
    }
    
    struct RoutingConfig: Codable {
        let rules: [RoutingRule]
        let fallbackRoute: String
        
        struct RoutingRule: Codable {
            let priority: Int
            let source: String
            let destination: String
            let action: Action
            
            enum Action: String, Codable {
                case allow, deny, redirect
            }
        }
    }
    
    struct EncryptionConfig: Codable {
        let algorithm: String
        let keySize: Int
        let rotation: RotationPolicy
        
        struct RotationPolicy: Codable {
            let enabled: Bool
            let interval: TimeInterval
            let onCompromise: Bool
        }
    }
    
    struct CertificateConfig: Codable {
        let validation: Bool
        let pinning: Bool
        let renewalThreshold: TimeInterval
    }
    
    struct FirewallRule: Codable {
        let id: UUID
        let name: String
        let priority: Int
        let action: Action
        let conditions: [Condition]
        
        enum Action: String, Codable {
            case allow, deny, log
        }
        
        struct Condition: Codable {
            let type: ConditionType
            let value: String
            
            enum ConditionType: String, Codable {
                case ipAddress
                case port
                case protocol
                case application
            }
        }
    }
    
    struct QoSConfig: Codable {
        let enabled: Bool
        let rules: [QoSRule]
        
        struct QoSRule: Codable {
            let priority: Int
            let bandwidth: BandwidthLimit
            let target: Target
            
            struct BandwidthLimit: Codable {
                let upload: Double
                let download: Double
            }
            
            struct Target: Codable {
                let type: TargetType
                let value: String
                
                enum TargetType: String, Codable {
                    case device
                    case application
                    case protocol
                }
            }
        }
    }
    
    struct OptimizationConfig: Codable {
        let compression: Bool
        let caching: Bool
        let prefetching: Bool
        let loadBalancing: Bool
    }
    
    struct MonitoringConfig: Codable {
        let interval: TimeInterval
        let metrics: Set<MetricType>
        let retention: TimeInterval
        
        enum MetricType: String, Codable {
            case performance
            case security
            case usage
            case errors
        }
    }
}
