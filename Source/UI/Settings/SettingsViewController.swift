import UIKit

class SettingsViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let settingsManager = SettingsManager.shared
    
    private enum Section: Int, CaseIterable {
        case connection
        case network
        case security
        case advanced
        
        var title: String {
            switch self {
            case .connection: return "Connection"
            case .network: return "Network"
            case .security: return "Security"
            case .advanced: return "Advanced"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureTableView()
    }
    
    private func setupUI() {
        title = "Settings"
        view.backgroundColor = .systemBackground
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: "SwitchCell")
    }
}

// MARK: - TableView Delegate & DataSource
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .connection: return 3
        case .network: return 4
        case .security: return 3
        case .advanced: return 2
        case .none: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Section(rawValue: section)?.title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .connection:
            return configureConnectionCell(at: indexPath)
        case .network:
            return configureNetworkCell(at: indexPath)
        case .security:
            return configureSecurityCell(at: indexPath)
        case .advanced:
            return configureAdvancedCell(at: indexPath)
        case .none:
            return UITableViewCell()
        }
    }
    
    private func configureConnectionCell(at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.configure(title: "Auto-Connect", isOn: settingsManager.autoConnect)
            cell.switchToggled = { [weak self] isOn in
                self?.settingsManager.autoConnect = isOn
            }
        case 1:
            cell.configure(title: "Keep Alive", isOn: settingsManager.keepAlive)
            cell.switchToggled = { [weak self] isOn in
                self?.settingsManager.keepAlive = isOn
            }
        case 2:
            cell.configure(title: "Battery Optimization", isOn: settingsManager.batteryOptimization)
            cell.switchToggled = { [weak self] isOn in
                self?.settingsManager.batteryOptimization = isOn
            }
        default:
            break
        }
        
        return cell
    }
    
    private func configureNetworkCell(at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "DNS Servers"
            cell.accessoryType = .disclosureIndicator
        case 1:
            cell.textLabel?.text = "MTU Size"
            cell.detailTextLabel?.text = "\(settingsManager.mtuSize)"
            cell.accessoryType = .disclosureIndicator
        case 2:
            cell.textLabel?.text = "IP Configuration"
            cell.accessoryType = .disclosureIndicator
        case 3:
            cell.textLabel?.text = "Traffic Rules"
            cell.accessoryType = .disclosureIndicator
        default:
            break
        }
        
        return cell
    }
    
    private func configureSecurityCell(at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchTableViewCell
        
        switch indexPath.row {
        case 0:
            cell.configure(title: "Data Encryption", isOn: settingsManager.dataEncryption)
            cell.switchToggled = { [weak self] isOn in
                self?.settingsManager.dataEncryption = isOn
            }
        case 1:
            cell.configure(title: "Secure DNS", isOn: settingsManager.secureDNS)
            cell.switchToggled = { [weak self] isOn in
                self?.settingsManager.secureDNS = isOn
            }
        case 2:
            cell.configure(title: "Kill Switch", isOn: settingsManager.killSwitch)
            cell.switchToggled = { [weak self] isOn in
                self?.settingsManager.killSwitch = isOn
            }
        default:
            break
        }
        
        return cell
    }
    
    private func configureAdvancedCell(at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "Logging"
            cell.accessoryType = .disclosureIndicator
        case 1:
            cell.textLabel?.text = "Debug Mode"
            cell.accessoryType = .disclosureIndicator
        default:
            break
        }
        
        return cell
    }
}

// MARK: - Custom Cells
class SwitchTableViewCell: UITableViewCell {
    private let toggleSwitch = UISwitch()
    var switchToggled: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSwitch()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSwitch() {
        toggleSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        accessoryView = toggleSwitch
    }
    
    func configure(title: String, isOn: Bool) {
        textLabel?.text = title
        toggleSwitch.isOn = isOn
    }
    
    @objc private func switchValueChanged() {
        switchToggled?(toggleSwitch.isOn)
    }
}
