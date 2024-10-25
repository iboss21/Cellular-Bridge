import Foundation

final class MetricsManager {
    static let shared = MetricsManager()
    
    private(set) var metrics: [NetworkMetrics] = []
    private let queue = DispatchQueue(label: "com.cellularbridge.metrics")
    private let maxStoredMetrics = 1000
    
    private var timer: Timer?
    
    private init() {
        startCollecting()
    }
    
    func startCollecting() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.collectMetrics()
        }
    }
    
    func stopCollecting() {
        timer?.invalidate()
        timer = nil
    }
    
    func getAverageMetrics(for timeInterval: TimeInterval) -> NetworkMetrics {
        let now = Date()
        let startDate = now.addingTimeInterval(-timeInterval)
        
        let relevantMetrics = metrics.filter { $0.timestamp >= startDate }
        
        guard !relevantMetrics.isEmpty else { return NetworkMetrics.zero }
        
        let avgUpload = relevantMetrics.map { $0.uploadSpeed }.reduce(0, +) / Double(relevantMetrics.count)
        let avgDownload = relevantMetrics.map { $0.downloadSpeed }.reduce(0, +) / Double(relevantMetrics.count)
        let avgDevices = relevantMetrics.map { $0.connectedDevices }.reduce(0, +) / relevantMetrics.count
        
        return NetworkMetrics(
            uploadSpeed: avgUpload,
            downloadSpeed: avgDownload,
            connectedDevices: avgDevices,
            timestamp: now
        )
    }
    
    private func collectMetrics() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            // Collect current metrics
            let currentMetrics = self.getCurrentMetrics()
            
            // Add to array
            self.metrics.append(currentMetrics)
            
            // Trim old metrics
            if self.metrics.count > self.maxStoredMetrics {
                self.metrics.removeFirst(self.metrics.count - self.maxStoredMetrics)
            }
            
            // Notify observers
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: .metricsUpdated,
                    object: currentMetrics
                )
            }
        }
    }
    
    private func getCurrentMetrics() -> NetworkMetrics {
        // Get current network statistics
        // This is a placeholder implementation
        return NetworkMetrics(
            uploadSpeed: Double.random(in: 0...1000),
            downloadSpeed: Double.random(in: 0...1000),
            connectedDevices: Int.random(in: 0...5),
            timestamp: Date()
        )
    }
}

extension Notification.Name {
    static let metricsUpdated = Notification.Name("metricsUpdated")
}
