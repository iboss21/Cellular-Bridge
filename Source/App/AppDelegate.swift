import UIKit
import NetworkExtension

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize Bridge Manager
        BridgeManager.shared.initialize()
        
        // Setup window and initial view controller
        window = UIWindow(frame: UIScreen.main.bounds)
        let mainViewController = MainViewController()
        let navigationController = UINavigationController(rootViewController: mainViewController)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        // Request necessary permissions
        requestPermissions()
        
        return true
    }
    
    private func requestPermissions() {
        // Request VPN permissions
        let vpnManager = NETunnelProviderManager()
        vpnManager.loadFromPreferences { error in
            if let error = error {
                print("Error loading VPN preferences: \(error)")
                return
            }
            
            vpnManager.saveToPreferences { error in
                if let error = error {
                    print("Error saving VPN preferences: \(error)")
                    return
                }
            }
        }
    }
}
