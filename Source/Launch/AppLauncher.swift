import UIKit

final class AppLauncher {
    private let window: UIWindow
    private let configuration: AppConfiguration
    private let servicesInitializer: ServicesInitializer
    
    init(window: UIWindow) {
        self.window = window
        self.configuration = AppConfiguration.shared
        self.servicesInitializer = ServicesInitializer()
    }
    
    func launch() {
        setupLogger()
        initializeServices()
        configureAppearance()
        setupRootViewController()
        
        window.makeKeyAndVisible()
    }
    
    private func setupLogger() {
        Logger.shared.configure(with: configuration)
        Logger.shared.log("App launching...", type: .info)
    }
    
    private func initializeServices() {
        servicesInitializer.initializeServices { result in
            switch result {
            case .success:
                Logger.shared.log("Services initialized successfully", type: .info)
            case .failure(let error):
                Logger.shared.log("Services initialization failed: \(error)", type: .error)
            }
        }
    }
    
    private func configureAppearance() {
        UINavigationBar.appearance().configure()
        UITabBar.appearance().configure()
    }
    
    private func setupRootViewController() {
        let mainViewController = MainTabBarController()
        let navigationController = UINavigationController(rootViewController: mainViewController)
        window.rootViewController = navigationController
    }
}

// MARK: - Services Initializer
final class ServicesInitializer {
    private let services: [ServiceInitializing] = [
        NetworkService(),
        SecurityService(),
        AnalyticsService(),
        StorageService(),
        BridgeService()
    ]
    
    func initializeServices(completion: @escaping (Result<Void, Error>) -> Void) {
        let group = DispatchGroup()
        var errors: [Error] = []
        
        services.forEach { service in
            group.enter()
            service.initialize { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    errors.append(error)
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            if errors.isEmpty {
                completion(.success(()))
            } else {
                completion(.failure(InitializationError.multiple(errors)))
            }
        }
    }
}

// MARK: - Service Protocol
protocol ServiceInitializing {
    func initialize(completion: @escaping (Result<Void, Error>) -> Void)
}

enum InitializationError: Error {
    case multiple([Error])
}

// MARK: - UIAppearance Extensions
extension UINavigationBar {
    func configure() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        
        standardAppearance = appearance
        scrollEdgeAppearance = appearance
        compactAppearance = appearance
        
        tintColor = .systemBlue
    }
}

extension UITabBar {
    func configure() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        
        standardAppearance = appearance
        scrollEdgeAppearance = appearance
        
        tintColor = .systemBlue
    }
}

// Example Usage:
/*
let window = UIWindow(frame: UIScreen.main.bounds)
let launcher = AppLauncher(window: window)
launcher.launch()
*/
