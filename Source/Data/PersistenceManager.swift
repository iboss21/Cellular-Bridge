import CoreData
import Foundation

final class PersistenceManager {
    static let shared = PersistenceManager()
    
    private let storeCoordinator: NSPersistentStoreCoordinator
    private let mainContext: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext
    
    // MARK: - Core Data Stack
    
    private init() {
        let container = NSPersistentContainer(name: "CellularBridge")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        
        self.storeCoordinator = container.persistentStoreCoordinator
        self.mainContext = container.viewContext
        
        self.backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        self.backgroundContext.persistentStoreCoordinator = storeCoordinator
        
        setupContexts()
    }
    
    private func setupContexts() {
        mainContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contextDidSave(_:)),
            name: .NSManagedObjectContextDidSave,
            object: nil
        )
    }
    
    // MARK: - Public Interface
    
    func saveContext() {
        saveContext(mainContext)
    }
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        backgroundContext.perform {
            block(self.backgroundContext)
            self.saveContext(self.backgroundContext)
        }
    }
    
    // MARK: - Private Methods
    
    private func saveContext(_ context: NSManagedObjectContext) {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            Logger.shared.log("Context save error: \(error)", type: .error)
        }
    }
    
    @objc private func contextDidSave(_ notification: Notification) {
        guard let context = notification.object as? NSManagedObjectContext else { return }
        
        if context === backgroundContext {
            mainContext.perform {
                self.mainContext.mergeChanges(fromContextDidSave: notification)
            }
        }
    }
}

// MARK: - Data Models
extension PersistenceManager {
    // Connection Records
    func saveConnectionRecord(_ record: ConnectionRecord) {
        performBackgroundTask { context in
            let entity = ConnectionRecordEntity(context: context)
            entity.id = record.id
            entity.timestamp = record.timestamp
            entity.duration = record.duration
            entity.bytesTransferred = Int64(record.bytesTransferred)
            entity.status = record.status.rawValue
        }
    }
    
    func fetchConnectionRecords(completion: @escaping ([ConnectionRecord]) -> Void) {
        performBackgroundTask { context in
            let request: NSFetchRequest<ConnectionRecordEntity> = ConnectionRecordEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            
            do {
                let entities = try context.fetch(request)
                let records = entities.map { ConnectionRecord(from: $0) }
                DispatchQueue.main.async {
                    completion(records)
                }
            } catch {
                Logger.shared.log("Failed to fetch connection records: \(error)", type: .error)
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
    
    // Performance Metrics
    func savePerformanceMetrics(_ metrics: PerformanceMetrics) {
        performBackgroundTask { context in
            let entity = PerformanceMetricsEntity(context: context)
            entity.id = metrics.id
            entity.timestamp = metrics.timestamp
            entity.cpuUsage = metrics.cpuUsage
            entity.memoryUsage = metrics.memoryUsage
            entity.networkLatency = metrics.networkLatency
        }
    }
    
    func fetchPerformanceMetrics(completion: @escaping ([PerformanceMetrics]) -> Void) {
        performBackgroundTask { context in
            let request: NSFetchRequest<PerformanceMetricsEntity> = PerformanceMetricsEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            
            do {
                let entities = try context.fetch(request)
                let metrics = entities.map { PerformanceMetrics(from: $0) }
                DispatchQueue.main.async {
                    completion(metrics)
                }
            } catch {
                Logger.shared.log("Failed to fetch performance metrics: \(error)", type: .error)
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
    
    // Error Logs
    func saveErrorLog(_ log: ErrorLog) {
        performBackgroundTask { context in
            let entity = ErrorLogEntity(context: context)
            entity.id = log.id
            entity.timestamp = log.timestamp
            entity.errorMessage = log.errorMessage
            entity.errorCode = log.errorCode
            entity.stackTrace = log.stackTrace
        }
    }
    
    func fetchErrorLogs(completion: @escaping ([ErrorLog]) -> Void) {
        performBackgroundTask { context in
            let request: NSFetchRequest<ErrorLogEntity> = ErrorLogEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            
            do {
                let entities = try context.fetch(request)
                let logs = entities.map { ErrorLog(from: $0) }
                DispatchQueue.main.async {
                    completion(logs)
                }
            } catch {
                Logger.shared.log("Failed to fetch error logs: \(error)", type: .error)
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
}

// MARK: - Model Mappings
extension ConnectionRecord {
    init(from entity: ConnectionRecordEntity) {
        self.id = entity.id ?? UUID()
        self.timestamp = entity.timestamp ?? Date()
        self.duration = entity.duration
        self.bytesTransferred = UInt64(entity.bytesTransferred)
        self.status = ConnectionStatus(rawValue: entity.status ?? "") ?? .disconnected
    }
}

extension PerformanceMetrics {
    init(from entity: PerformanceMetricsEntity) {
        self.id = entity.id ?? UUID()
        self.timestamp = entity.timestamp ?? Date()
        self.cpuUsage = entity.cpuUsage
        self.memoryUsage = entity.memoryUsage
        self.networkLatency = entity.networkLatency
    }
}

extension ErrorLog {
    init(from entity: ErrorLogEntity) {
        self.id = entity.id ?? UUID()
        self.timestamp = entity.timestamp ?? Date()
        self.errorMessage = entity.errorMessage ?? ""
        self.errorCode = entity.errorCode ?? ""
        self.stackTrace = entity.stackTrace
    }
}
