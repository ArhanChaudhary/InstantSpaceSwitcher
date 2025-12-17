import SwiftUI
import AppKit

@MainActor
struct HotkeyPreferencesView: View {
    @ObservedObject private var store: HotkeyStore
    @State private var recordingIdentifier: HotkeyIdentifier?
    @State private var statusMessage: String?
    @State private var statusColor: Color = .secondary

    init(store: HotkeyStore = .shared) {
        _store = ObservedObject(wrappedValue: store)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Shortcuts")
                .font(.title3)
                .bold()

            VStack(alignment: .leading, spacing: 16) {
                preferenceRow(for: .left)
                preferenceRow(for: .right)
            }

            Divider()

            HStack {
                Button("Restore Defaults", action: restoreDefaults)
                Spacer()
                if let message = statusMessage {
                    Text(message)
                        .foregroundStyle(statusColor)
                        .font(.callout)
                }
            }
        }
        .padding(24)
        .frame(width: 360)
        .onDisappear {
            HotkeyRecorder.shared.endRecording()
        }
    }

    private func preferenceRow(for identifier: HotkeyIdentifier) -> some View {
        let combination = store.combination(for: identifier)
        let isRecording = recordingIdentifier == identifier

        return VStack(alignment: .leading, spacing: 8) {
            Text(identifier.displayName)
                .font(.headline)

            HStack {
                Text(combination.displayString)
                    .monospaced()
                    .foregroundStyle(.primary)

                Spacer()

                Button(isRecording ? "Press shortcut…" : "Change…") {
                    toggleRecording(for: identifier)
                }
                .keyboardShortcut(.defaultAction)
                .controlSize(.small)
                .disabled(isRecording && recordingIdentifier != identifier)

                Button("Reset") {
                    reset(identifier)
                }
                .controlSize(.small)
            }

            if isRecording {
                Text("Press the desired key combination. Press Esc to cancel.")
                    .foregroundStyle(.secondary)
                    .font(.caption)
            }
        }
    }

    private func toggleRecording(for identifier: HotkeyIdentifier) {
        let shouldBegin = recordingIdentifier != identifier
        HotkeyRecorder.shared.endRecording()

        guard shouldBegin else {
            recordingIdentifier = nil
            statusMessage = "Cancelled recording."
            statusColor = .secondary
            return
        }

        recordingIdentifier = identifier
        statusMessage = "Waiting for new shortcut…"
        statusColor = .secondary

        HotkeyRecorder.shared.beginRecording(for: identifier) { combination in
            handleRecordingResult(combination, for: identifier)
        } cancellation: {
            recordingIdentifier = nil
            statusMessage = "Cancelled recording."
            statusColor = .secondary
        }
    }

    private func handleRecordingResult(_ combination: HotkeyCombination, for identifier: HotkeyIdentifier) {
        let otherIdentifier = identifier.other
        if store.combination(for: otherIdentifier) == combination {
            NSSound.beep()
            statusMessage = "Shortcut already used for \(otherIdentifier.displayName)."
            statusColor = .red
            recordingIdentifier = nil
            return
        }

        store.update(combination, for: identifier)
        statusMessage = "Updated \(identifier.displayName) shortcut."
        statusColor = .primary
        recordingIdentifier = nil
    }

    private func reset(_ identifier: HotkeyIdentifier) {
        switch identifier {
        case .left:
            store.update(.defaultLeft, for: .left)
        case .right:
            store.update(.defaultRight, for: .right)
        }
        statusMessage = "Reset \(identifier.displayName) shortcut."
        statusColor = .primary
    }

    private func restoreDefaults() {
        store.resetToDefaults()
        statusMessage = "Restored default shortcuts."
        statusColor = .primary
        recordingIdentifier = nil
    }
}

private extension HotkeyIdentifier {
    var displayName: String {
        switch self {
        case .left:
            return "Switch Left"
        case .right:
            return "Switch Right"
        }
    }

    var other: HotkeyIdentifier {
        switch self {
        case .left: return .right
        case .right: return .left
        }
    }
}
