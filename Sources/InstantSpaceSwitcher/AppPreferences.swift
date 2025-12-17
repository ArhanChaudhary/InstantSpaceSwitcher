import AppKit
import Combine

@MainActor
final class AppPreferences: ObservableObject {
    static let shared = AppPreferences()

    private enum Keys {
        static let showSpaceNumber = "showSpaceNumber"
        static let showSpaceNumberInIcon = "showSpaceNumberInIcon"
    }

    @Published var showSpaceNumber: Bool {
        didSet {
            defaults.set(showSpaceNumber, forKey: Keys.showSpaceNumber)
        }
    }

    @Published var showSpaceNumberInIcon: Bool {
        didSet {
            defaults.set(showSpaceNumberInIcon, forKey: Keys.showSpaceNumberInIcon)
        }
    }

    private let defaults: UserDefaults

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if defaults.object(forKey: Keys.showSpaceNumber) != nil {
            showSpaceNumber = defaults.bool(forKey: Keys.showSpaceNumber)
        } else {
            showSpaceNumber = false
        }

        if defaults.object(forKey: Keys.showSpaceNumberInIcon) != nil {
            showSpaceNumberInIcon = defaults.bool(forKey: Keys.showSpaceNumberInIcon)
        } else {
            showSpaceNumberInIcon = false
        }
    }
}
