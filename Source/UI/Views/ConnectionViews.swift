import UIKit

// MARK: - Connection Status View
class ConnectionStatusView: UIView {
    private let statusLabel = UILabel()
    private let statusIndicator = UIView()
    private let detailsLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Configure status indicator
        statusIndicator.layer.cornerRadius = 6
        statusIndicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(statusIndicator)
        
        // Configure labels
        statusLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(statusLabel)
        
        detailsLabel.font = .systemFont(ofSize: 14)
        detailsLabel.textColor = .secondaryLabel
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(detailsLabel)
        
        NSLayoutConstraint.activate([
            statusIndicator.leadingAnchor.constraint(equalTo: leadingAnchor),
            statusIndicator.centerYAnchor.constraint(equalTo: statusLabel.centerYAnchor),
            statusIndicator.widthAnchor.constraint(equalToConstant: 12),
            statusIndicator.heightAnchor.constraint(equalToConstant: 12),
            
            statusLabel.leadingAnchor.constraint(equalTo: statusIndicator.trailingAnchor, constant: 8),
            statusLabel.topAnchor.constraint(equalTo: topAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            detailsLabel.leadingAnchor.constraint(equalTo: statusLabel.leadingAnchor),
            detailsLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 4),
            detailsLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func updateStatus(connected: Bool) {
        statusIndicator.backgroundColor = connected ? .systemGreen : .systemRed
        statusLabel.text = connected ? "Connected" : "Disconnected"
        detailsLabel.text = connected ? "Data bridge is active" : "Data bridge is inactive"
    }
}

// MARK: - Connection Control View
class ConnectionControlView: UIView {
    private let connectButton = UIButton(type: .system)
    var onConnectTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        connectButton.translatesAutoresizingMaskIntoConstraints = false
        connectButton.layer.cornerRadius = 12
        connectButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        connectButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        addSubview(connectButton)
        
        NSLayoutConstraint.activate([
            connectButton.topAnchor.constraint(equalTo: topAnchor),
            connectButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            connectButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            connectButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        updateButton(connected: false)
    }
    
    func updateButton(connected: Bool) {
        connectButton.setTitle(connected ? "Disconnect" : "Connect", for: .normal)
        connectButton.backgroundColor = connected ? .systemRed : .systemBlue
        connectButton.setTitleColor(.white, for: .normal)
    }
    
    @objc private func buttonTapped() {
        onConnectTapped?()
    }
}

// MARK: - Network Metrics View
class NetworkMetricsView: UIView {
    private let uploadSpeedLabel = UILabel()
    private let downloadSpeedLabel = UILabel()
    private let devicesLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Configure labels
        [uploadSpeedLabel, downloadSpeedLabel, devicesLabel].forEach {
            $0.font = .monospacedSystemFont(ofSize: 14, weight: .regular)
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            uploadSpeedLabel.topAnchor.constraint(equalTo: topAnchor),
            uploadSpeedLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            downloadSpeedLabel.topAnchor.constraint(equalTo: uploadSpeedLabel.bottomAnchor, constant: 8),
            downloadSpeedLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            devicesLabel.topAnchor.constraint(equalTo: downloadSpeedLabel.bottomAnchor, constant: 8),
            devicesLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
        ])
    }
    
    func updateMetrics(_ metrics: NetworkMetrics) {
        uploadSpeedLabel.text = "↑ \(formatSpeed(metrics.uploadSpeed))"
        downloadSpeedLabel.text = "↓ \(formatSpeed(metrics.downloadSpeed))"
        devicesLabel.text = "Connected Devices: \(metrics.connectedDevices)"
    }
    
    private func formatSpeed(_ speed: Double) -> String {
        if speed < 1024 {
            return String(format: "%.1f KB/s", speed)
        } else {
            return String(format: "%.1f MB/s", speed / 1024)
        }
    }
}
