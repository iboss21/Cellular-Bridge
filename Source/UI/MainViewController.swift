import UIKit
import NetworkExtension

class MainViewController: UIViewController {
    // UI Components
    private let statusView = ConnectionStatusView()
    private let controlView = ConnectionControlView()
    private let metricsView = NetworkMetricsView()
    private let settingsButton = UIButton(type: .system)
    
    // Managers
    private let bridgeManager = BridgeManager.shared
    private let metricsManager = MetricsManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupNotifications()
        setupActions()
    }
    
    private func setupUI() {
        title = "Cellular Bridge"
        view.backgroundColor = .systemBackground
        
        // Configure components
        [statusView, controlView, metricsView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        // Settings button
        settingsButton.setImage(UIImage(systemName: "gear"), for: .normal)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            statusView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            statusView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            controlView.topAnchor.constraint(equalTo: statusView.bottomAnchor, constant: 20),
            controlView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            controlView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            metricsView.topAnchor.constraint(equalTo: controlView.bottomAnchor, constant: 20),
            metricsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            metricsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            metricsView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(connectionStatusChanged),
            name: .bridgeConnectionStatusChanged,
            object: nil
        )
    }
    
    private func setupActions() {
        controlView.onConnectTapped = { [weak self] in
            self?.toggleConnection()
        }
        
        settingsButton.addTarget(self, action: #selector(showSettings), for: .touchUpInside)
    }
    
    private func toggleConnection() {
        if bridgeManager.isConnected {
            bridgeManager.stopBridge { [weak self] error in 
                self?.handleConnectionResult(error)
            }
        } else {
            bridgeManager.startBridge { [weak self] error in
                self?.handleConnectionResult(error)
            }
        }
    }
    
    private func handleConnectionResult(_ error: Error?) {
        if let error = error {
            showAlert(title: "Connection Error", message: error.localizedDescription)
        }
        updateUI()
    }
    
    private func updateUI() {
        statusView.updateStatus(connected: bridgeManager.isConnected)
        controlView.updateButton(connected: bridgeManager.isConnected)
        metricsView.updateMetrics(metricsManager.currentMetrics)
    }
    
    @objc private func connectionStatusChanged() {
        updateUI()
    }
    
    @objc private func showSettings() {
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
