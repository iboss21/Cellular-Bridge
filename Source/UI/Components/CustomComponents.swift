import UIKit

// MARK: - Gradient Button
class GradientButton: UIButton {
    private let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        layer.cornerRadius = bounds.height / 2
        gradientLayer.cornerRadius = bounds.height / 2
    }
    
    private func setupButton() {
        layer.masksToBounds = true
        
        gradientLayer.colors = AppColors.Gradients.primary
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        layer.insertSublayer(gradientLayer, at: 0)
        
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
    }
    
    func setGradientColors(_ colors: [CGColor]) {
        gradientLayer.colors = colors
    }
}

// MARK: - Status Badge View
class StatusBadgeView: UIView {
    private let statusLabel = UILabel()
    private let iconView = UIImageView()
    
    var status: ConnectionStatus = .disconnected {
        didSet {
            updateStatus()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.masksToBounds = true
        
        // Configure icon
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .white
        
        // Configure label
        statusLabel.font = .systemFont(ofSize: 14, weight: .medium)
        statusLabel.textColor = .white
        
        // Add subviews
        addSubview(iconView)
        addSubview(statusLabel)
        
        // Setup constraints
        iconView.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            iconView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 16),
            iconView.heightAnchor.constraint(equalToConstant: 16),
            
            statusLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 4),
            statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            statusLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        updateStatus()
    }
    
    private func updateStatus() {
        switch status {
        case .connected:
            backgroundColor = AppColors.shared.success
            iconView.image = UIImage(systemName: "checkmark.circle.fill")
            statusLabel.text = "Connected"
            
        case .connecting:
            backgroundColor = AppColors.shared.warning
            iconView.image = UIImage(systemName: "arrow.2.circlepath")
            statusLabel.text = "Connecting"
            
        case .disconnected:
            backgroundColor = AppColors.shared.error
            iconView.image = UIImage(systemName: "xmark.circle.fill")
            statusLabel.text = "Disconnected"
        }
    }
}

enum ConnectionStatus {
    case connected
    case connecting
    case disconnected
}

// MARK: - Metrics Card View
class MetricsCardView: UIView {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private let iconView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        layer.masksToBounds = true
        
        applyShadow(
            color: .black,
            opacity: 0.1,
            radius: 10,
            offset: CGSize(width: 0, height: 5)
        )
        
        // Configure labels
        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.textColor = .secondaryLabel
        
        valueLabel.font = .systemFont(ofSize: 24, weight: .bold)
        valueLabel.textColor = .label
        
        // Configure icon
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = AppColors.shared.primary
        
        // Add subviews
        addSubview(titleLabel)
        addSubview(valueLabel)
        addSubview(iconView)
        
        // Setup constraints
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        iconView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            iconView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            valueLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    func configure(title: String, value: String, icon: UIImage?) {
        titleLabel.text = title
        valueLabel.text = value
        iconView.image = icon
    }
}
