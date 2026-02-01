import AppKit
import ServiceManagement

final class GeneralSettingsViewController: NSViewController {
    private let showOSDCheckbox = NSButton(checkboxWithTitle: "Show on-screen display when switching spaces", target: nil, action: nil)
    private let launchAtLoginCheckbox = NSButton(checkboxWithTitle: "Launch at login", target: nil, action: nil)
    
    private let defaults = UserDefaults.standard
    
    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 500, height: 300))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadSettings()
    }
    
    private func setupUI() {
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.alignment = .leading
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let generalLabel = NSTextField(labelWithString: "General Settings")
        generalLabel.font = NSFont.boldSystemFont(ofSize: 13)
        
        showOSDCheckbox.target = self
        showOSDCheckbox.action = #selector(showOSDChanged)
        
        launchAtLoginCheckbox.target = self
        launchAtLoginCheckbox.action = #selector(launchAtLoginChanged)
        
        stackView.addArrangedSubview(generalLabel)
        stackView.addArrangedSubview(showOSDCheckbox)
        stackView.addArrangedSubview(launchAtLoginCheckbox)
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func loadSettings() {
        showOSDCheckbox.state = defaults.bool(forKey: "showOSD") ? .on : .off
        launchAtLoginCheckbox.state = SMAppService.mainApp.status == .enabled ? .on : .off
    }
    
    @objc private func showOSDChanged(_ sender: NSButton) {
        defaults.set(sender.state == .on, forKey: "showOSD")
    }
    
    @objc private func launchAtLoginChanged(_ sender: NSButton) {
        let shouldEnable = sender.state == .on
        
        do {
            if shouldEnable {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSSound.beep()
            sender.state = shouldEnable ? .off : .on
            
            let alert = NSAlert()
            alert.messageText = "Failed to \(shouldEnable ? "enable" : "disable") launch at login"
            alert.informativeText = error.localizedDescription
            alert.alertStyle = .warning
            alert.runModal()
        }
    }
}
