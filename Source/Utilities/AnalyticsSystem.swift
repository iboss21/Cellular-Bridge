import Foundation

final class AnalyticsSystem {
    static let shared = AnalyticsSystem()
    
    private var events: [AnalyticEvent] = []
    private let queue = DispatchQueue(label: "com.cellularbridge.analytics")
    private let storage = AnalyticsStorage()
    
    private init() {
        loadStoredEvents()
    }
    
    func trackEvent(_ event: AnalyticEvent) {
        queue.async { [weak self] in
            self?.events.append(event)
            self?.storage.save(event)
            self?.processEvent(event)
        }
    }
    
    func getEvents(ofType type: EventType) -> [AnalyticEvent] {
        queue.sync {
            return events.filter { $0.type == type }
        }
    }
    
    func clearEvents() {
        queue.async { [weak self] in
            self?.events.removeAll()
            self?.storage.clearEvents()
        }
    }
    
    private func loadStoredEvents() {
        events = storage.loadEvents()
    }
    
    private func processEvent(_ event: AnalyticEvent) {
        switch event.type {
        case .connection:
            processConnectionEvent(event)
        case .error:
            processErrorEvent(event)
        case .performance:
            processPerformanceEvent(event)
        case .security:
            processSecurityEvent(event)
        }
    }
    
    private func processConnectionEvent(_ event: AnalyticEvent) {
        // Process connection-related analytics
        NotificationCenter.default.post(
            name: .connectionEventProcessed,
            object: event
        )
    }
    
    private func processErrorEvent(_ event: AnalyticEvent) {
        // Process error-related analytics
        Logger.shared.log("Error event: \(event.name)", type: .error)
    }
    
    private func processPerformanceEvent(_ event: AnalyticEvent) {
        // Process performance-related analytics
        MetricsManager.shared.processPerformanceEvent(event)
    }
    
    private func processSecurityEvent(_ event: AnalyticEvent) {
        // Process security-related analytics
        SecurityManager.shared.processSecurityEvent(event)
    }
}

// MARK: - Analytics Models
struct AnalyticEvent: Codable {
    let id: UUID
    let type: EventType
    let name: String
    let timestamp: Date
    let metadata: [String: String]
    
    init(type: EventType, name: String, metadata: [String: String] = [:]) {
        self.id = UUID()
        self.type = type
        self.name = name
        self.timestamp = Date()
        self.metadata = metadata
    }
}

enum EventType: String, Codable {
    case connection
    case error
    case performance
    case security
}

// MARK: - Analytics Storage
private class AnalyticsStorage {
    private let fileManager = FileManager.default
    private let storageURL: URL
    
    init() {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        storageURL = documentsPath.appendingPathComponent("analytics.json")
    }
    
    func save(_ event: AnalyticEvent) {
        var events = loadEvents()
        events.append(event)
        saveEvents(events)
    }
    
    func loadEvents() -> [AnalyticEvent] {
        guard let data = try? Data(contentsOf: storageURL),
              let events = try? JSONDecoder().decode([AnalyticEvent].self, from: data) else {
            return []
        }
        return events
    }
    
    func saveEvents(_ events: [AnalyticEvent]) {
        guard let data = try? JSONEncoder().encode(events) else { return }
        try? data.write(to: storageURL)
    }
    
    func clearEvents() {
        try? fileManager.removeItem(at: storageURL)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let connectionEventProcessed = Notification.Name("connectionEventProcessed")
}

// MARK: - Analytics Usage Example
/*
// Track connection event
AnalyticsSystem.shared.trackEvent(
    AnalyticEvent(
        type: .connection,
        name: "connection_established",
        metadata: [
            "duration": "120",
            "speed": "10.5"
        ]
    )
)

// Track error event
AnalyticsSystem.shared.trackEvent(
    AnalyticEvent(
        type: .error,
        name: "connection_failed",
        metadata: [
            "error_code": "E001",
            "reason": "timeout"
        ]
    )
)
*/
