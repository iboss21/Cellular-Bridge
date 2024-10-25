import Foundation

final class AnalyticsSystem {
    static let shared = AnalyticsSystem()
    
    private let eventTracker = EventTracker()
    private let sessionManager = SessionManager()
    private let metricsCollector = MetricsCollector()
    private let storageManager = AnalyticsStorageManager()
    private let networkManager = AnalyticsNetworkManager()
    
    // Analytics Configuration
    private struct Config {
        static let maxStoredEvents = 1000
        static let batchSize = 100
        static let uploadInterval: TimeInterval = 300 // 5 minutes
        static let retentionPeriod: TimeInterval = 7 * 24 * 3600 // 7 days
    }
    
    private init() {
        setupAnalytics()
    }
    
    func startSession() {
        sessionManager.startNewSession()
        trackEvent(.sessionStart)
        startMetricsCollection()
    }
    
    func endSession() {
        trackEvent(.sessionEnd)
        sessionManager.endCurrentSession()
        uploadPendingData()
    }
    
    func trackEvent(_ type: AnalyticEventType, parameters: [String: Any] = [:]) {
        let event = AnalyticEvent(
            type: type,
            parameters: parameters,
            timestamp: Date(),
            sessionId: sessionManager.currentSessionId
        )
        
        eventTracker.track(event)
        storageManager.store(event)
        
        if eventTracker.pendingEventsCount >= Config.batchSize {
            uploadPendingData()
        }
    }
    
    private func setupAnalytics() {
        setupEventTracking()
        setupMetricsCollection()
        setupDataUpload()
        setupDataRetention()
    }
    
    private func startMetricsCollection() {
        metricsCollector.startCollecting { [weak self] metrics in
            self?.processMetrics(metrics)
        }
    }
    
    private func processMetrics(_ metrics: AnalyticsMetrics) {
        trackEvent(.metrics, parameters: metrics.toDictionary())
    }
    
    private func uploadPendingData() {
        let events = eventTracker.getPendingEvents()
        let metrics = metricsCollector.getCurrentMetrics()
        
        networkManager.uploadAnalytics(events: events, metrics: metrics) { [weak self] result in
            switch result {
            case .success:
                self?.eventTracker.clearPendingEvents()
            case .failure(let error):
                Logger.shared.log("Analytics upload failed: \(error)", type: .error)
            }
        }
    }
}

// MARK: - Event Tracker
final class EventTracker {
    private var pendingEvents: [AnalyticEvent] = []
    private let queue = DispatchQueue(label: "com.cellularbridge.analytics.events")
    
    var pendingEventsCount: Int {
        queue.sync { pendingEvents.count }
    }
    
    func track(_ event: AnalyticEvent) {
        queue.async {
            self.pendingEvents.append(event)
        }
    }
    
    func getPendingEvents() -> [AnalyticEvent] {
        queue.sync { pendingEvents }
    }
    
    func clearPendingEvents() {
        queue.async {
            self.pendingEvents.removeAll()
        }
    }
}

// MARK: - Session Manager
final class SessionManager {
    private(set) var currentSessionId: String?
    private var sessionStartTime: Date?
    
    func startNewSession() {
        currentSessionId = UUID().uuidString
        sessionStartTime = Date()
    }
    
    func endCurrentSession() {
        currentSessionId = nil
        sessionStartTime = nil
    }
    
    func getSessionDuration() -> TimeInterval? {
        guard let startTime = sessionStartTime else { return nil }
        return Date().timeIntervalSince(startTime)
    }
}

// MARK: - Metrics Collector
final class MetricsCollector {
    typealias MetricsHandler = (AnalyticsMetrics) -> Void
    
    private var timer: Timer?
    private var currentMetrics: AnalyticsMetrics?
    private var metricsHandler: MetricsHandler?
    
    func startCollecting(handler: @escaping MetricsHandler) {
        metricsHandler = handler
        
        timer = Timer.scheduledTimer(
            withTimeInterval: 60,
            repeats: true
        ) { [weak self] _ in
            self?.collectMetrics()
        }
    }
    
    func getCurrentMetrics() -> AnalyticsMetrics {
        return currentMetrics ?? AnalyticsMetrics()
    }
    
    private func collectMetrics() {
        let metrics = AnalyticsMetrics(
            cpuUsage: measureCPUUsage(),
            memoryUsage: measureMemoryUsage(),
            networkUsage: measureNetworkUsage(),
            batteryLevel: measureBatteryLevel()
        )
        
        currentMetrics = metrics
        metricsHandler?(metrics)
    }
    
    private func measureCPUUsage() -> Double {
        // Implement CPU usage measurement
        return 0.0
    }
    
    private func measureMemoryUsage() -> Double {
        // Implement memory usage measurement
        return 0.0
    }
    
    private func measureNetworkUsage() -> NetworkUsage {
        // Implement network usage measurement
        return NetworkUsage(bytesIn: 0, bytesOut: 0)
    }
    
    private func measureBatteryLevel() -> Double {
        // Implement battery level measurement
        return 0.0
    }
}

// MARK: - Analytics Storage Manager
final class AnalyticsStorageManager {
    private let fileManager = FileManager.default
    private let storageURL: URL
    
    init() {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        storageURL = documentsPath.appendingPathComponent("analytics")
        createStorageDirectoryIfNeeded()
    }
    
    func store(_ event: AnalyticEvent) {
        let fileName = "\(event.id).json"
        let fileURL = storageURL.appendingPathComponent(fileName)
        
        do {
            let data = try JSONEncoder().encode(event)
            try data.write(to: fileURL)
        } catch {
            Logger.shared.log("Failed to store analytics event: \(error)", type: .error)
        }
    }
    
    private func createStorageDirectoryIfNeeded() {
        guard !fileManager.fileExists(atPath: storageURL.path) else { return }
        
        do {
            try fileManager.createDirectory(
                at: storageURL,
                withIntermediateDirectories: true
            )
        } catch {
            Logger.shared.log("Failed to create analytics storage directory: \(error)", type: .error)
        }
    }
}

// MARK: - Analytics Network Manager
final class AnalyticsNetworkManager {
    func uploadAnalytics(events: [AnalyticEvent], metrics: AnalyticsMetrics, completion: @escaping (Result<Void, Error>) -> Void) {
        let payload = AnalyticsPayload(events: events, metrics: metrics)
        
        // In a real implementation, this would send the data to your analytics server
        // For now, we'll just simulate the upload
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            completion(.success(()))
        }
    }
}

// MARK: - Analytics Models
struct AnalyticEvent: Codable {
    let id: String = UUID().uuidString
    let type: AnalyticEventType
    let parameters: [String: AnyCodable]
    let timestamp: Date
    let sessionId: String?
}

enum AnalyticEventType: String, Codable {
    case sessionStart
    case sessionEnd
    case connectionEstablished
    case connectionFailed
    case dataTransfer
    case error
    case metrics
}

struct AnalyticsMetrics: Codable {
    let cpuUsage: Double
    let memoryUsage: Double
    let networkUsage: NetworkUsage
    let batteryLevel: Double
    
    func toDictionary() -> [String: Any] {
        return [
            "cpuUsage": cpuUsage,
            "memoryUsage": memoryUsage,
            "networkUsage": networkUsage.toDictionary(),
            "batteryLevel": batteryLevel
        ]
    }
}

struct NetworkUsage: Codable {
    let bytesIn: UInt64
    let bytesOut: UInt64
    
    func toDictionary() -> [String: Any] {
        return [
            "bytesIn": bytesIn,
            "bytesOut": bytesOut
        ]
    }
}

struct AnalyticsPayload: Codable {
    let events: [AnalyticEvent]
    let metrics: AnalyticsMetrics
    let timestamp: Date = Date()
}

// MARK: - AnyCodable
struct AnyCodable: Codable {
    private let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self.value = ()
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.value = dictionary
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "AnyCodable value cannot be decoded"
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case is Void:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(
                value,
                EncodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "AnyCodable value cannot be encoded"
                )
            )
        }
    }
}
