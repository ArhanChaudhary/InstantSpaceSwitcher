import Foundation
import AppKit
import Carbon

struct HotkeyCombination: Codable, Equatable {
    var keyCode: UInt32
    var modifiers: UInt32
    var displayKey: String
    var keyEquivalent: String

    var displayString: String {
        let modifierSymbols = HotkeyCombination.symbols(for: modifiers)
        return modifierSymbols + displayKey
    }

    var cocoaModifierFlags: NSEvent.ModifierFlags {
        var flags: NSEvent.ModifierFlags = []
        if modifiers & UInt32(cmdKey) != 0 { flags.insert(.command) }
        if modifiers & UInt32(optionKey) != 0 { flags.insert(.option) }
        if modifiers & UInt32(controlKey) != 0 { flags.insert(.control) }
        if modifiers & UInt32(shiftKey) != 0 { flags.insert(.shift) }
        return flags
    }

    var isValid: Bool {
        modifiers != 0 && !displayKey.isEmpty
    }

    static let defaultLeft = HotkeyCombination(
        keyCode: UInt32(kVK_LeftArrow),
        modifiers: HotkeyCombination.defaultModifierMask,
        displayKey: "←",
        keyEquivalent: HotkeyCombination.arrowKeyEquivalent(.leftArrow)
    )

    static let defaultRight = HotkeyCombination(
        keyCode: UInt32(kVK_RightArrow),
        modifiers: HotkeyCombination.defaultModifierMask,
        displayKey: "→",
        keyEquivalent: HotkeyCombination.arrowKeyEquivalent(.rightArrow)
    )

    static func from(event: NSEvent) -> HotkeyCombination? {
        let modifiers = event.modifierFlags.carbonMask
        guard modifiers != 0 else { return nil }

        let keyCode = UInt32(event.keyCode)
        if let special = event.specialKey, let symbol = arrowSymbol(for: special) {
            return HotkeyCombination(
                keyCode: keyCode,
                modifiers: modifiers,
                displayKey: symbol,
                keyEquivalent: arrowKeyEquivalent(special)
            )
        }

        guard let characters = event.charactersIgnoringModifiers, let first = characters.first else {
            return nil
        }

        let upper = String(first).uppercased()
        return HotkeyCombination(
            keyCode: keyCode,
            modifiers: modifiers,
            displayKey: upper,
            keyEquivalent: String(first).lowercased()
        )
    }

    static func arrowSymbol(for specialKey: NSEvent.SpecialKey) -> String? {
        switch specialKey {
        case .leftArrow: return "←"
        case .rightArrow: return "→"
        case .upArrow: return "↑"
        case .downArrow: return "↓"
        default: return nil
        }
    }

    private static func arrowKeyEquivalent(_ specialKey: NSEvent.SpecialKey) -> String {
        switch specialKey {
        case .leftArrow:
            return String(Character(UnicodeScalar(NSLeftArrowFunctionKey)!))
        case .rightArrow:
            return String(Character(UnicodeScalar(NSRightArrowFunctionKey)!))
        case .upArrow:
            return String(Character(UnicodeScalar(NSUpArrowFunctionKey)!))
        case .downArrow:
            return String(Character(UnicodeScalar(NSDownArrowFunctionKey)!))
        default:
            return ""
        }
    }

    private static func symbols(for modifiers: UInt32) -> String {
        var result = ""
        if modifiers & UInt32(cmdKey) != 0 { result += "⌘" }
        if modifiers & UInt32(optionKey) != 0 { result += "⌥" }
        if modifiers & UInt32(controlKey) != 0 { result += "⌃" }
        if modifiers & UInt32(shiftKey) != 0 { result += "⇧" }
        return result
    }

    private static var defaultModifierMask: UInt32 {
        UInt32(cmdKey) | UInt32(optionKey) | UInt32(controlKey)
    }
}

enum HotkeyIdentifier: String, CaseIterable {
    case left
    case right
}

final class HotkeyStore: ObservableObject {
    static let shared = HotkeyStore()

    @Published private(set) var leftHotkey: HotkeyCombination
    @Published private(set) var rightHotkey: HotkeyCombination

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        leftHotkey = defaults.hotkey(forKey: DefaultsKey.left.rawValue) ?? .defaultLeft
        rightHotkey = defaults.hotkey(forKey: DefaultsKey.right.rawValue) ?? .defaultRight
    }

    func update(_ combination: HotkeyCombination, for identifier: HotkeyIdentifier) {
        switch identifier {
        case .left:
            guard combination != leftHotkey else { return }
            leftHotkey = combination
            defaults.setHotkey(combination, forKey: DefaultsKey.left.rawValue)
        case .right:
            guard combination != rightHotkey else { return }
            rightHotkey = combination
            defaults.setHotkey(combination, forKey: DefaultsKey.right.rawValue)
        }
    }

    func resetToDefaults() {
        leftHotkey = .defaultLeft
        rightHotkey = .defaultRight
        defaults.setHotkey(leftHotkey, forKey: DefaultsKey.left.rawValue)
        defaults.setHotkey(rightHotkey, forKey: DefaultsKey.right.rawValue)
    }

    func combination(for identifier: HotkeyIdentifier) -> HotkeyCombination {
        switch identifier {
        case .left: return leftHotkey
        case .right: return rightHotkey
        }
    }

    private enum DefaultsKey: String {
        case left = "hotkey.left"
        case right = "hotkey.right"
    }
}

private extension UserDefaults {
    func hotkey(forKey key: String) -> HotkeyCombination? {
        guard let data = data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(HotkeyCombination.self, from: data)
    }

    func setHotkey(_ hotkey: HotkeyCombination, forKey key: String) {
        if let data = try? JSONEncoder().encode(hotkey) {
            set(data, forKey: key)
        }
    }
}

extension NSEvent.ModifierFlags {
    var carbonMask: UInt32 {
        var mask: UInt32 = 0
        if contains(.command) { mask |= UInt32(cmdKey) }
        if contains(.option) { mask |= UInt32(optionKey) }
        if contains(.control) { mask |= UInt32(controlKey) }
        if contains(.shift) { mask |= UInt32(shiftKey) }
        return mask
    }
}
