import UIKit

// MARK: - Main Dashboard View
final class DashboardViewController: UIViewController {
    private let statusCard = ConnectionStatusCard()
    private let metricsPanel = MetricsPanel()
    private let devicesList = ConnectedDevicesListView()
    private let controlPanel = ControlPanelView()
    
    private let bridgeManager = BridgeManager.shared
    private let analyticsSystem = AnalyticsSystem.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureBindings()
        startMonitoring()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Cellular Bridge"
        
        // Add subviews
        [statusCard, metricsPanel, devicesList, controlPanel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            // Status Card
            statusCard.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            statusCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statusCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            statusCard.heightAnchor.constraint(equalToConstant: 120),
            
            // Metrics Panel
            metricsPanel.topAnchor.constraint(equalTo: statusCard.bottomAnchor, constant: 16),
            metricsPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            metricsPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            metricsPanel.heightAnchor.constraint(equalToConstant: 180),
            
            // Devices List
            devicesList.topAnchor.constraint(equalTo: metricsPanel.bottomAnchor, constant: 16),
            devicesList.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            devicesList.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            devicesList.heightAnchor.constraint(equalToConstant: 200),
            
            // Control Panel
            controlPanel.topAnchor.constraint(equalTo: devicesList.bottomAnchor, constant: 16),
            controlPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            controlPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            controlPanel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}

// MARK: - Status Card View
final class ConnectionStatusCard: UIView {
    private let statusLabel = UILabel()
    private let connectionTypeLabel = UILabel()
    private let statusIcon = UIImageView()
    private let detailsStack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCard()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCard() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        applyShadow()
        
        // Configure Status Label
        statusLabel.font = .systemFont(ofSize: 24, weight: .bold)
        statusLabel.textAlignment = .center
        
        // Configure Connection Type Label
        connectionTypeLabel.font = .systemFont(ofSize: 16, weight: .medium)
        connectionTypeLabel.textColor = .secondaryLabel
        connectionTypeLabel.textAlignment = .center
        
        // Configure Status Icon
        statusIcon.contentMode = .scaleAspectFit
        statusIcon.tintColor = .systemGreen
        
        // Configure Details Stack
        detailsStack.axis = .vertical
        detailsStack.spacing = 8
        detailsStack.alignment = .center
        
        // Add subviews
        [statusIcon, statusLabel, connectionTypeLabel].forEach {
            detailsStack.addArrangedSubview($0)
        }
        
        addSubview(detailsStack)
        detailsStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            detailsStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            detailsStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            statusIcon.widthAnchor.constraint(equalToConstant: 40),
            statusIcon.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    func updateStatus(_ status: ConnectionStatus) {
        switch status {
        case .connected(let type):
            statusLabel.text = "Connected"
            connectionTypeLabel.text = type.description
            statusIcon.image = UIImage(systemName: "checkmark.circle.fill")
            statusIcon.tintColor = .systemGreen
            
        case .connecting:
            statusLabel.text = "Connecting"
            connectionTypeLabel.text = "Establishing Connection"
            statusIcon.image = UIImage(systemName: "arrow.2.circlepath")
            statusIcon.tintColor = .systemYellow
            
        case .disconnected:
            statusLabel.text = "Disconnected"
            connectionTypeLabel.text = "Not Connected"
            statusIcon.image = UIImage(systemName: "xmark.circle.fill")
            statusIcon.tintColor = .systemRed
            
        case .unknown:
            statusLabel.text = "Unknown"
            connectionTypeLabel.text = "Check Connection"
            statusIcon.image = UIImage(systemName: "questionmark.circle.fill")
            statusIcon.tintColor = .systemGray
        }
    }
}

// MARK: - Metrics Panel View
final class MetricsPanel: UIView {
    private let uploadSpeedView = MetricView(title: "Upload")
    private let downloadSpeedView = MetricView(title: "Download")
    private let latencyView = MetricView(title: "Latency")
    private let devicesView = MetricView(title: "Devices")
    
    private let metricsStack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPanel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPanel() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        applyShadow()
        
        // Configure Stack
        metricsStack.axis = .horizontal
        metricsStack.distribution = .fillEqually
        metricsStack.spacing = 16
        
        // Add metric views
        [uploadSpeedView, downloadSpeedView, latencyView, devicesView].forEach {
            metricsStack.addArrangedSubview($0)
        }
        
        addSubview(metricsStack)
        metricsStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            metricsStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            metricsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            metricsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            metricsStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    func updateMetrics(_ metrics: NetworkMetrics) {
        uploadSpeedView.setValue(formatSpeed(metrics.uploadSpeed))
        downloadSpeedView.setValue(formatSpeed(metrics.downloadSpeed))
        latencyView.setValue(formatLatency(metrics.latency))
        devicesView.setValue("\(metrics.connectedDevices)")
    }
    
    private func formatSpeed(_ speed: Double) -> String {
        if speed >= 1024 {
            return String(format: "%.1f MB/s", speed / 1024)
        } else {
            return String(format: "%.1f KB/s", speed)
        }
    }
    
    private func formatLatency(_ latency: TimeInterval) -> String {
        return String(format: "%.0f ms", latency * 1000)
    }
}

// MARK: - Connected Devices List View
final class ConnectedDevicesListView: UIView {
    private let tableView = UITableView()
    private var devices: [ConnectedDevice] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupList()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupList() {
        backgroundColor = .systemBackground
        
        // Configure Table View
        tableView.register(DeviceCell.self, forCellReuseIdentifier: "DeviceCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func updateDevices(_ devices: [ConnectedDevice]) {
        self.devices = devices
        tableView.reloadData()
    }
}

// MARK: - Control Panel View
final class ControlPanelView: UIView {
    private let connectButton = GradientButton()
    private let settingsButton = UIButton(type: .system)
    private let helpButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPanel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupPanel() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        applyShadow()
        
        // Configure Connect Button
        connectButton.setTitle("Connect", for: .normal)
        connectButton.addTarget(self, action: #selector(connectTapped), for: .touchUpInside)
        
        // Configure Settings Button
        settingsButton.setTitle("Settings", for: .normal)
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        
        // Configure Help Button
        helpButton.setTitle("Help", for: .normal)
        helpButton.addTarget(self, action: #selector(helpTapped), for: .touchUpInside)
        
        // Add subviews
        [connectButton, settingsButton, helpButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            connectButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            connectButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            connectButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            connectButton.heightAnchor.constraint(equalToConstant: 50),
            
            settingsButton.topAnchor.constraint(equalTo: connectButton.bottomAnchor, constant: 16),
            settingsButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            settingsButton.heightAnchor.constraint(equalToConstant: 44),
            
            helpButton.topAnchor.constraint(equalTo: connectButton.bottomAnchor, constant: 16),
            helpButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            helpButton.heightAnchor.constraint(equalToConstant: 44),
            helpButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    @objc private func connectTapped() {
        // Handle connect action
    }
    
    @objc private func settingsTapped() {
        // Handle settings action
    }
    
    @objc private func helpTapped() {
        // Handle help action
    }
}
