import AppKit
import ApplicationServices
import Carbon
import Foundation
import Security

private enum AppConfig {
    static let keychainService = "com.guowei.supergoal"
    static let keychainAccount = "openai-api-key"
    static let apiKeyDefaultsKey = "api-key"
    static let defaultBaseURL = "https://api.openai.com/v1/responses"
    static let defaultModel = "gpt-5.1"
    static let baseURLDefaultsKey = "base-url"
    static let modelDefaultsKey = "model"
    static let customCompilerPromptDefaultsKey = "custom-compiler-prompt"
    static let maxCustomCompilerPromptLength = 8000
    static let shortcutKeyCodeDefaultsKey = "shortcut-key-code"
    static let shortcutModifiersDefaultsKey = "shortcut-modifiers"
    static let defaultShortcutKeyCode = UInt32(kVK_ANSI_G)
    static let defaultShortcutModifiers = UInt32(controlKey | optionKey | cmdKey)
}

private struct HotKeyShortcut: Equatable {
    let keyCode: UInt32
    let modifiers: UInt32

    static let defaultValue = HotKeyShortcut(
        keyCode: AppConfig.defaultShortcutKeyCode,
        modifiers: AppConfig.defaultShortcutModifiers
    )

    var isValid: Bool {
        keyCode > 0 || keyCode == UInt32(kVK_ANSI_A)
    }

    var displayString: String {
        var parts: [String] = []
        if modifiers & UInt32(controlKey) != 0 { parts.append("⌃") }
        if modifiers & UInt32(optionKey) != 0 { parts.append("⌥") }
        if modifiers & UInt32(shiftKey) != 0 { parts.append("⇧") }
        if modifiers & UInt32(cmdKey) != 0 { parts.append("⌘") }
        parts.append(Self.keyName(for: keyCode))
        return parts.joined()
    }

    static func fromDefaults() -> HotKeyShortcut {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: AppConfig.shortcutKeyCodeDefaultsKey) != nil,
              defaults.object(forKey: AppConfig.shortcutModifiersDefaultsKey) != nil else {
            return .defaultValue
        }

        let keyCode = UInt32(defaults.integer(forKey: AppConfig.shortcutKeyCodeDefaultsKey))
        let modifiers = UInt32(defaults.integer(forKey: AppConfig.shortcutModifiersDefaultsKey))
        let shortcut = HotKeyShortcut(keyCode: keyCode, modifiers: modifiers)
        return shortcut.isValid && shortcut.modifiers != 0 ? shortcut : .defaultValue
    }

    static func fromEvent(_ event: NSEvent) -> HotKeyShortcut? {
        let modifiers = carbonModifiers(from: event.modifierFlags)
        let primaryModifiers = modifiers & UInt32(controlKey | optionKey | cmdKey)
        guard primaryModifiers != 0 else { return nil }
        return HotKeyShortcut(keyCode: UInt32(event.keyCode), modifiers: modifiers)
    }

    static func carbonModifiers(from flags: NSEvent.ModifierFlags) -> UInt32 {
        var result: UInt32 = 0
        if flags.contains(.control) { result |= UInt32(controlKey) }
        if flags.contains(.option) { result |= UInt32(optionKey) }
        if flags.contains(.shift) { result |= UInt32(shiftKey) }
        if flags.contains(.command) { result |= UInt32(cmdKey) }
        return result
    }

    private static func keyName(for keyCode: UInt32) -> String {
        let names: [UInt32: String] = [
            UInt32(kVK_ANSI_A): "A", UInt32(kVK_ANSI_B): "B", UInt32(kVK_ANSI_C): "C",
            UInt32(kVK_ANSI_D): "D", UInt32(kVK_ANSI_E): "E", UInt32(kVK_ANSI_F): "F",
            UInt32(kVK_ANSI_G): "G", UInt32(kVK_ANSI_H): "H", UInt32(kVK_ANSI_I): "I",
            UInt32(kVK_ANSI_J): "J", UInt32(kVK_ANSI_K): "K", UInt32(kVK_ANSI_L): "L",
            UInt32(kVK_ANSI_M): "M", UInt32(kVK_ANSI_N): "N", UInt32(kVK_ANSI_O): "O",
            UInt32(kVK_ANSI_P): "P", UInt32(kVK_ANSI_Q): "Q", UInt32(kVK_ANSI_R): "R",
            UInt32(kVK_ANSI_S): "S", UInt32(kVK_ANSI_T): "T", UInt32(kVK_ANSI_U): "U",
            UInt32(kVK_ANSI_V): "V", UInt32(kVK_ANSI_W): "W", UInt32(kVK_ANSI_X): "X",
            UInt32(kVK_ANSI_Y): "Y", UInt32(kVK_ANSI_Z): "Z",
            UInt32(kVK_ANSI_0): "0", UInt32(kVK_ANSI_1): "1", UInt32(kVK_ANSI_2): "2",
            UInt32(kVK_ANSI_3): "3", UInt32(kVK_ANSI_4): "4", UInt32(kVK_ANSI_5): "5",
            UInt32(kVK_ANSI_6): "6", UInt32(kVK_ANSI_7): "7", UInt32(kVK_ANSI_8): "8",
            UInt32(kVK_ANSI_9): "9",
            UInt32(kVK_ANSI_Minus): "-", UInt32(kVK_ANSI_Equal): "=",
            UInt32(kVK_ANSI_LeftBracket): "[", UInt32(kVK_ANSI_RightBracket): "]",
            UInt32(kVK_ANSI_Backslash): "\\", UInt32(kVK_ANSI_Semicolon): ";",
            UInt32(kVK_ANSI_Quote): "'", UInt32(kVK_ANSI_Comma): ",",
            UInt32(kVK_ANSI_Period): ".", UInt32(kVK_ANSI_Slash): "/",
            UInt32(kVK_ANSI_Grave): "`", UInt32(kVK_Space): "Space",
            UInt32(kVK_Return): "Return", UInt32(kVK_Tab): "Tab",
            UInt32(kVK_Delete): "Delete", UInt32(kVK_Escape): "Esc",
            UInt32(kVK_LeftArrow): "←", UInt32(kVK_RightArrow): "→",
            UInt32(kVK_UpArrow): "↑", UInt32(kVK_DownArrow): "↓",
            UInt32(kVK_F1): "F1", UInt32(kVK_F2): "F2", UInt32(kVK_F3): "F3",
            UInt32(kVK_F4): "F4", UInt32(kVK_F5): "F5", UInt32(kVK_F6): "F6",
            UInt32(kVK_F7): "F7", UInt32(kVK_F8): "F8", UInt32(kVK_F9): "F9",
            UInt32(kVK_F10): "F10", UInt32(kVK_F11): "F11", UInt32(kVK_F12): "F12",
            UInt32(kVK_F13): "F13", UInt32(kVK_F14): "F14", UInt32(kVK_F15): "F15",
            UInt32(kVK_F16): "F16", UInt32(kVK_F17): "F17", UInt32(kVK_F18): "F18",
            UInt32(kVK_F19): "F19", UInt32(kVK_F20): "F20"
        ]
        return names[keyCode] ?? "Key \(keyCode)"
    }
}

private enum SupergoalError: Error, LocalizedError {
    case message(String)

    var errorDescription: String? {
        switch self {
        case .message(let text):
            return text
        }
    }
}

private enum DebugLog {
    static let url = URL(fileURLWithPath: "/tmp/supergoal.log")

    static func write(_ message: String) {
        let formatter = ISO8601DateFormatter()
        let line = "\(formatter.string(from: Date())) \(message)\n"
        guard let data = line.data(using: .utf8) else { return }

        if FileManager.default.fileExists(atPath: url.path),
           let handle = try? FileHandle(forWritingTo: url) {
            defer { try? handle.close() }
            _ = try? handle.seekToEnd()
            try? handle.write(contentsOf: data)
        } else {
            try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try? data.write(to: url)
        }
    }
}

private enum KeychainStore {
    static func readAPIKey() -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: AppConfig.keychainService,
            kSecAttrAccount as String: AppConfig.keychainAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }

    static func saveAPIKey(_ value: String) throws {
        let baseQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: AppConfig.keychainService,
            kSecAttrAccount as String: AppConfig.keychainAccount
        ]

        SecItemDelete(baseQuery as CFDictionary)

        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: AppConfig.keychainService,
            kSecAttrAccount as String: AppConfig.keychainAccount,
            kSecValueData as String: Data(value.utf8)
        ]

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw SupergoalError.message("Keychain save failed with status \(status).")
        }
    }
}

private struct ClipboardSnapshot {
    let items: [[NSPasteboard.PasteboardType: Data]]

    static func capture() -> ClipboardSnapshot {
        let copiedItems: [[NSPasteboard.PasteboardType: Data]] = NSPasteboard.general.pasteboardItems?.map { item in
            var copiedData: [NSPasteboard.PasteboardType: Data] = [:]
            for type in item.types {
                if let data = item.data(forType: type) {
                    copiedData[type] = data
                }
            }
            return copiedData
        } ?? []
        return ClipboardSnapshot(items: copiedItems)
    }

    func restore() {
        NSPasteboard.general.clearContents()
        let restoredItems = items.map { itemData in
            let item = NSPasteboardItem()
            for (type, data) in itemData {
                item.setData(data, forType: type)
            }
            return item
        }
        if !restoredItems.isEmpty {
            NSPasteboard.general.writeObjects(restoredItems)
        }
    }
}

private final class OpenAIClient {
    private enum Endpoint {
        case responses(URL)
        case chatCompletions(URL)

        var url: URL {
            switch self {
            case .responses(let url), .chatCompletions(let url):
                return url
            }
        }
    }

    static func compileSupergoal(
        apiKey: String,
        baseURL: String,
        model: String,
        compilerPrompt: String,
        rawRequest: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let endpoints: [Endpoint]
        do {
            endpoints = try endpointCandidates(from: baseURL)
        } catch {
            completion(.failure(error))
            return
        }

        performRequest(endpoints: endpoints, index: 0, apiKey: apiKey, model: model, compilerPrompt: compilerPrompt, rawRequest: rawRequest, lastError: nil, completion: completion)
    }

    private static func performRequest(
        endpoints: [Endpoint],
        index: Int,
        apiKey: String,
        model: String,
        compilerPrompt: String,
        rawRequest: String,
        lastError: Error?,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard index < endpoints.count else {
            completion(.failure(lastError ?? SupergoalError.message("No API endpoint candidates were available.")))
            return
        }

        let endpoint = endpoints[index]
        var request = URLRequest(url: endpoint.url)
        request.httpMethod = "POST"
        request.timeoutInterval = 90
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload(for: endpoint, model: model, compilerPrompt: compilerPrompt, rawRequest: rawRequest), options: [])
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                performRequest(endpoints: endpoints, index: index + 1, apiKey: apiKey, model: model, compilerPrompt: compilerPrompt, rawRequest: rawRequest, lastError: error, completion: completion)
                return
            }

            guard let data else {
                let error = SupergoalError.message("API returned no data from \(endpoint.url.absoluteString).")
                performRequest(endpoints: endpoints, index: index + 1, apiKey: apiKey, model: model, compilerPrompt: compilerPrompt, rawRequest: rawRequest, lastError: error, completion: completion)
                return
            }

            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            do {
                if statusCode < 200 || statusCode >= 300 {
                    let apiMessage = extractErrorMessage(from: data)
                    throw SupergoalError.message(apiMessage ?? "API request failed with HTTP \(statusCode) at \(endpoint.url.absoluteString).")
                }

                guard let text = extractOutputText(from: data), !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    throw SupergoalError.message("API response did not contain output text from \(endpoint.url.absoluteString).")
                }

                completion(.success(text.trimmingCharacters(in: .whitespacesAndNewlines)))
            } catch {
                performRequest(endpoints: endpoints, index: index + 1, apiKey: apiKey, model: model, compilerPrompt: compilerPrompt, rawRequest: rawRequest, lastError: error, completion: completion)
            }
        }.resume()
    }

    private static func payload(for endpoint: Endpoint, model: String, compilerPrompt: String, rawRequest: String) -> [String: Any] {
        switch endpoint {
        case .responses:
            return [
                "model": model,
                "instructions": compilerPrompt,
                "input": userPrompt(rawRequest: rawRequest),
                "max_output_tokens": 600,
                "temperature": 0.2,
                "store": false
            ]
        case .chatCompletions:
            return [
                "model": model,
                "messages": [
                    ["role": "system", "content": compilerPrompt],
                    ["role": "user", "content": userPrompt(rawRequest: rawRequest)]
                ],
                "max_tokens": 600,
                "temperature": 0.2,
                "stream": false
            ]
        }
    }

    private static let systemPrompt = """
    Convert the user's rough Codex task into a compact goal-mode prompt. Output only the prompt. Use the user's language. Do not invent a repo path; say to work in the current Codex conversation context. Include concise sections: Goal, Use $supergoal and $superdev, Context, Scope, Non-goals, Stop, Acceptance, Verify. Preserve intent, ignore complaints/examples unless needed, forbid broad rewrites/new frameworks/speculative abstractions, require focused verification. Keep under 700 words.
    """

    static func effectiveCompilerPrompt(from customPrompt: String) -> String {
        let trimmed = customPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? systemPrompt : trimmed
    }

    private static func userPrompt(rawRequest: String) -> String {
        """
        Raw user request:
        \(rawRequest)
        """
    }

    private static func endpointCandidates(from value: String) throws -> [Endpoint] {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let base = trimmed.isEmpty ? AppConfig.defaultBaseURL : trimmed
        guard var components = URLComponents(string: base), components.scheme != nil, components.host != nil else {
            throw SupergoalError.message("Base URL is invalid.")
        }

        let trimmedPath = components.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let path = trimmedPath.isEmpty ? "" : "/" + trimmedPath

        func url(withPath path: String) throws -> URL {
            components.path = path
            guard let url = components.url else {
                throw SupergoalError.message("Base URL is invalid.")
            }
            return url
        }

        if path.hasSuffix("/responses") {
            return [.responses(try url(withPath: path))]
        }

        if path.hasSuffix("/chat/completions") {
            return [.chatCompletions(try url(withPath: path))]
        }

        if path.isEmpty {
            if trimmed.isEmpty {
                return [.responses(try url(withPath: "/v1/responses"))]
            }
            return [
                .chatCompletions(try url(withPath: "/v1/chat/completions")),
                .responses(try url(withPath: "/v1/responses"))
            ]
        }

        if path.hasSuffix("/v1") {
            return [
                .chatCompletions(try url(withPath: path + "/chat/completions")),
                .responses(try url(withPath: path + "/responses"))
            ]
        }

        return [
            .chatCompletions(try url(withPath: path + "/v1/chat/completions")),
            .responses(try url(withPath: path + "/v1/responses"))
        ]
    }

    private static func extractOutputText(from data: Data) -> String? {
        guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        if let text = root["output_text"] as? String {
            return text
        }

        if let choices = root["choices"] as? [[String: Any]] {
            for choice in choices {
                if let message = choice["message"] as? [String: Any], let content = message["content"] as? String {
                    return content
                }
                if let text = choice["text"] as? String {
                    return text
                }
            }
        }

        var fragments: [String] = []
        if let output = root["output"] as? [[String: Any]] {
            for item in output {
                guard let content = item["content"] as? [[String: Any]] else { continue }
                for part in content {
                    if let text = part["text"] as? String {
                        fragments.append(text)
                    }
                }
            }
        }

        return fragments.isEmpty ? nil : fragments.joined(separator: "\n")
    }

    private static func extractErrorMessage(from data: Data) -> String? {
        guard let root = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return String(data: data, encoding: .utf8)
        }

        if let error = root["error"] as? [String: Any], let message = error["message"] as? String {
            return message
        }

        return String(data: data, encoding: .utf8)
    }
}

private final class ShortcutRecorderButton: NSButton {
    var shortcut: HotKeyShortcut = .defaultValue {
        didSet { updateTitle() }
    }
    var onChange: ((HotKeyShortcut) -> Void)?
    private var isRecording = false

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        target = self
        action = #selector(startRecording)
        bezelStyle = .rounded
        setButtonType(.momentaryPushIn)
        focusRingType = .default
        updateTitle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var acceptsFirstResponder: Bool { true }

    @objc private func startRecording() {
        isRecording = true
        title = "Press shortcut..."
        window?.makeFirstResponder(self)
    }

    override func keyDown(with event: NSEvent) {
        guard isRecording else {
            super.keyDown(with: event)
            return
        }
        record(event)
    }

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if isRecording {
            record(event)
            return true
        }
        return super.performKeyEquivalent(with: event)
    }

    override func resignFirstResponder() -> Bool {
        if isRecording {
            isRecording = false
            updateTitle()
        }
        return super.resignFirstResponder()
    }

    private func record(_ event: NSEvent) {
        if event.keyCode == UInt16(kVK_Escape) {
            isRecording = false
            updateTitle()
            return
        }

        guard let nextShortcut = HotKeyShortcut.fromEvent(event) else {
            NSSound.beep()
            title = "Use ⌘, ⌥, or ⌃"
            return
        }

        isRecording = false
        shortcut = nextShortcut
        onChange?(nextShortcut)
        window?.makeFirstResponder(nil)
    }

    private func updateTitle() {
        title = shortcut.displayString
    }
}

private final class SettingsWindowController: NSWindowController {
    private let apiKeyField = NSSecureTextField()
    private let baseURLField = NSTextField()
    private let modelField = NSTextField()
    private let shortcutButton = ShortcutRecorderButton(frame: .zero)
    private var selectedShortcut: HotKeyShortcut
    private let onSave: (String, String, String, HotKeyShortcut) -> Void

    init(
        apiKey: String,
        baseURL: String,
        model: String,
        shortcut: HotKeyShortcut,
        onSave: @escaping (String, String, String, HotKeyShortcut) -> Void
    ) {
        self.onSave = onSave
        self.selectedShortcut = shortcut

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 274),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "supergoal settings"
        window.level = .floating
        window.isReleasedWhenClosed = false
        window.center()
        super.init(window: window)

        apiKeyField.stringValue = apiKey
        apiKeyField.placeholderString = "sk-..."
        baseURLField.stringValue = baseURL
        baseURLField.placeholderString = AppConfig.defaultBaseURL
        modelField.stringValue = model
        shortcutButton.shortcut = shortcut
        shortcutButton.onChange = { [weak self] shortcut in
            self?.selectedShortcut = shortcut
        }

        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func build() {
        guard let contentView = window?.contentView else { return }

        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 22)
        ])

        stack.addArrangedSubview(fieldRow(label: "OpenAI key", field: apiKeyField))
        stack.addArrangedSubview(fieldRow(label: "Base URL", field: baseURLField))
        stack.addArrangedSubview(fieldRow(label: "Model", field: modelField))
        stack.addArrangedSubview(shortcutRow())

        let row = NSStackView()
        row.orientation = .horizontal
        row.alignment = .centerY
        row.spacing = 8
        let spacer = NSView()
        row.addArrangedSubview(spacer)

        let saveButton = NSButton(title: "Save", target: self, action: #selector(save))
        saveButton.bezelStyle = .rounded
        row.addArrangedSubview(saveButton)

        stack.addArrangedSubview(row)
        row.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
    }

    private func fieldRow(label: String, field: NSTextField) -> NSView {
        let row = NSStackView()
        row.orientation = .horizontal
        row.alignment = .centerY
        row.spacing = 10

        let labelView = NSTextField(labelWithString: label)
        labelView.textColor = .secondaryLabelColor
        labelView.alignment = .right
        labelView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        row.addArrangedSubview(labelView)
        row.addArrangedSubview(field)
        field.widthAnchor.constraint(equalToConstant: 400).isActive = true

        return row
    }

    private func shortcutRow() -> NSView {
        let row = NSStackView()
        row.orientation = .horizontal
        row.alignment = .centerY
        row.spacing = 10

        let labelView = NSTextField(labelWithString: "Shortcut")
        labelView.textColor = .secondaryLabelColor
        labelView.alignment = .right
        labelView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        row.addArrangedSubview(labelView)

        shortcutButton.widthAnchor.constraint(equalToConstant: 180).isActive = true
        row.addArrangedSubview(shortcutButton)

        let defaultButton = NSButton(title: "Default", target: self, action: #selector(resetShortcut))
        defaultButton.bezelStyle = .rounded
        row.addArrangedSubview(defaultButton)

        return row
    }

    @objc private func resetShortcut() {
        selectedShortcut = .defaultValue
        shortcutButton.shortcut = .defaultValue
    }

    @objc private func save() {
        onSave(apiKeyField.stringValue, baseURLField.stringValue, modelField.stringValue, selectedShortcut)
        close()
    }
}

private final class CompilerPromptWindowController: NSWindowController {
    private let promptTextView = NSTextView()
    private let errorLabel = NSTextField(labelWithString: "")
    private let onSave: (String) -> Void

    init(customCompilerPrompt: String, onSave: @escaping (String) -> Void) {
        self.onSave = onSave

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 620, height: 360),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "custom compiler prompt"
        window.level = .floating
        window.isReleasedWhenClosed = false
        window.center()
        super.init(window: window)

        promptTextView.string = customCompilerPrompt
        build()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func build() {
        guard let contentView = window?.contentView else { return }

        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -18)
        ])

        let hint = NSTextField(labelWithString: "Leave empty to use the built-in compiler prompt.")
        hint.textColor = .secondaryLabelColor
        stack.addArrangedSubview(hint)

        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .bezelBorder
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.widthAnchor.constraint(equalToConstant: 576).isActive = true
        scrollView.heightAnchor.constraint(equalToConstant: 220).isActive = true

        promptTextView.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        promptTextView.isRichText = false
        promptTextView.isAutomaticQuoteSubstitutionEnabled = false
        promptTextView.isAutomaticDashSubstitutionEnabled = false
        promptTextView.textContainerInset = NSSize(width: 8, height: 8)
        promptTextView.minSize = NSSize(width: 0, height: 220)
        promptTextView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        promptTextView.isVerticallyResizable = true
        promptTextView.isHorizontallyResizable = false
        promptTextView.textContainer?.widthTracksTextView = true
        scrollView.documentView = promptTextView
        stack.addArrangedSubview(scrollView)

        errorLabel.textColor = .systemRed
        errorLabel.isHidden = true
        stack.addArrangedSubview(errorLabel)

        let controls = NSStackView()
        controls.orientation = .horizontal
        controls.alignment = .centerY
        controls.spacing = 8

        let clearButton = NSButton(title: "Clear", target: self, action: #selector(clearPrompt))
        clearButton.bezelStyle = .rounded
        controls.addArrangedSubview(clearButton)

        let spacer = NSView()
        controls.addArrangedSubview(spacer)

        let saveButton = NSButton(title: "Save", target: self, action: #selector(save))
        saveButton.bezelStyle = .rounded
        controls.addArrangedSubview(saveButton)

        stack.addArrangedSubview(controls)
        controls.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }

    @objc private func clearPrompt() {
        promptTextView.string = ""
        errorLabel.isHidden = true
    }

    @objc private func save() {
        let customPrompt = promptTextView.string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard customPrompt.count <= AppConfig.maxCustomCompilerPromptLength else {
            errorLabel.stringValue = "Compiler prompt is too long. Keep it under \(AppConfig.maxCustomCompilerPromptLength) characters."
            errorLabel.isHidden = false
            NSSound.beep()
            return
        }

        onSave(customPrompt)
        close()
    }
}

private final class PixelKeyboardView: NSView {
    private var timer: Timer?
    private var frameIndex = 0
    private var startedAt = Date()

    override var isFlipped: Bool { true }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.masksToBounds = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startAnimating() {
        guard timer == nil else { return }
        startedAt = Date()
        let timer = Timer(timeInterval: 0.11, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.frameIndex = (self.frameIndex + 1) % 5
            self.needsDisplay = true
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func stopAnimating() {
        timer?.invalidate()
        timer = nil
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }

        context.saveGState()
        context.setShouldAntialias(false)
        context.interpolationQuality = .none
        let entrance = min(max(CGFloat(Date().timeIntervalSince(startedAt)) / 0.16, 0), 1)
        context.setAlpha(entrance)
        drawPixelKeyboard(context: context)
        context.restoreGState()
    }

    private func drawPixelKeyboard(context: CGContext) {
        let accent = NSColor.controlAccentColor.usingColorSpace(.deviceRGB) ?? NSColor(calibratedRed: 0.28, green: 0.54, blue: 1.0, alpha: 1)
        let x: CGFloat = 8
        let y: CGFloat = 10
        let keyDark = NSColor(calibratedWhite: 0.09, alpha: 0.74)
        let keyMid = NSColor(calibratedWhite: 0.62, alpha: 0.54)
        let keyLight = NSColor(calibratedWhite: 0.88, alpha: 0.76)

        pixelRect(x: x + 3, y: y + 25, width: 58, height: 3, color: NSColor.black.withAlphaComponent(0.16))
        pixelRect(x: x, y: y + 4, width: 62, height: 25, color: keyDark)
        pixelRect(x: x + 2, y: y + 2, width: 58, height: 2, color: NSColor(calibratedWhite: 0.80, alpha: 0.20))
        pixelRect(x: x + 2, y: y + 6, width: 58, height: 20, color: NSColor(calibratedWhite: 0.16, alpha: 0.84))

        drawKeys(origin: NSPoint(x: x + 6, y: y + 8), accent: accent, keyMid: keyMid, keyLight: keyLight)
        drawTypedPixels(origin: NSPoint(x: x + 68, y: y + 9), accent: accent)
    }

    private func drawKeys(origin: NSPoint, accent: NSColor, keyMid: NSColor, keyLight: NSColor) {
        let activeByFrame: [[Int]] = [
            [1, 10],
            [4, 12, 19],
            [7, 15],
            [2, 8, 21],
            [5, 17]
        ]
        let active = Set(activeByFrame[frameIndex])
        var keyIndex = 0

        for row in 0..<3 {
            let rowY = origin.y + CGFloat(row) * 6
            let columns = row == 0 ? 8 : (row == 1 ? 7 : 5)
            let rowX = origin.x + CGFloat(row) * 3
            for column in 0..<columns {
                let keyWidth: CGFloat = row == 2 && column == 2 ? 12 : 4
                let keyX = rowX + CGFloat(column) * 6 + (row == 2 && column > 2 ? 8 : 0)
                let isActive = active.contains(keyIndex)
                let fill = isActive ? accent.withAlphaComponent(0.88) : keyMid
                pixelRect(x: keyX, y: rowY, width: keyWidth, height: 3, color: fill)
                if !isActive {
                    pixelRect(x: keyX, y: rowY, width: keyWidth, height: 1, color: keyLight.withAlphaComponent(0.22))
                }
                keyIndex += 1
            }
        }
    }

    private func drawTypedPixels(origin: NSPoint, accent: NSColor) {
        let count = min(frameIndex + 1, 4)
        for index in 0..<count {
            let x = origin.x + CGFloat(index) * 6
            let y = origin.y + CGFloat((index + frameIndex) % 2) * 3
            drawGlyph(origin: NSPoint(x: x, y: y), color: accent.withAlphaComponent(0.34 + CGFloat(index) * 0.10))
        }

        let cursorX = origin.x + CGFloat(count) * 6 + 2
        let cursorAlpha: CGFloat = frameIndex % 2 == 0 ? 0.82 : 0.34
        pixelRect(x: cursorX, y: origin.y + 3, width: 2, height: 9, color: accent.withAlphaComponent(cursorAlpha))
    }

    private func drawGlyph(origin: NSPoint, color: NSColor) {
        pixelRect(x: origin.x, y: origin.y, width: 2, height: 2, color: color)
        pixelRect(x: origin.x + 3, y: origin.y + 3, width: 2, height: 2, color: color)
        pixelRect(x: origin.x, y: origin.y + 6, width: 5, height: 2, color: color)
    }

    private func pixelRect(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: NSColor) {
        color.setFill()
        NSBezierPath(rect: NSRect(x: floor(x), y: floor(y), width: floor(width), height: floor(height))).fill()
    }
}

private final class PixelKeyboardPanel: NSPanel {
    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
    override var acceptsFirstResponder: Bool { false }
}

private final class GlowHUDController {
    private var panel: NSPanel?
    private var keyboardView: PixelKeyboardView?

    func show(stage: String, anchor: NSRect? = nil) {
        DebugLog.write("pixel keyboard show stage=\(stage)")
        if let panel, let keyboardView {
            resize(panel, keyboardView: keyboardView, anchor: anchor)
            panel.orderFrontRegardless()
            return
        }

        let frame = frame(for: anchor)
        let panel = PixelKeyboardPanel(contentRect: frame, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        let view = PixelKeyboardView(frame: NSRect(origin: .zero, size: frame.size))

        panel.contentView = view
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.ignoresMouseEvents = true
        panel.hidesOnDeactivate = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle, .transient]

        self.panel = panel
        self.keyboardView = view
        panel.alphaValue = 0
        panel.orderFrontRegardless()
        view.startAnimating()

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.10
            panel.animator().alphaValue = 1
        }
    }

    func update(stage: String, anchor: NSRect? = nil) {
        show(stage: stage, anchor: anchor)
    }

    func hide(completion: (() -> Void)? = nil) {
        guard let panel else {
            completion?()
            return
        }
        DebugLog.write("pixel keyboard hide")
        keyboardView?.stopAnimating()

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.12
            panel.animator().alphaValue = 0
        } completionHandler: { [weak self] in
            panel.orderOut(nil)
            if self?.panel === panel {
                self?.panel = nil
                self?.keyboardView = nil
            }
            completion?()
        }
    }

    private func resize(_ panel: NSPanel, keyboardView: PixelKeyboardView, anchor: NSRect?) {
        let nextFrame = frame(for: anchor)
        panel.setFrame(nextFrame, display: true)
        keyboardView.frame = NSRect(origin: .zero, size: nextFrame.size)
    }

    private func frame(for anchor: NSRect?) -> NSRect {
        let size = NSSize(width: 100, height: 42)
        let mouse = NSEvent.mouseLocation
        let screen: NSScreen?
        var origin: NSPoint

        if let anchor, !anchor.isEmpty {
            let anchorCenter = NSPoint(x: anchor.midX, y: anchor.midY)
            screen = NSScreen.screens.first { NSMouseInRect(anchorCenter, $0.frame, false) } ?? NSScreen.main
            let visibleFrame = screen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
            let x = min(max(anchor.minX + 12, visibleFrame.minX + 10), visibleFrame.maxX - size.width - 10)
            let belowY = anchor.minY - size.height - 6
            let aboveY = anchor.maxY + 6
            let y: CGFloat

            if belowY >= visibleFrame.minY + 10 {
                y = belowY
                DebugLog.write("pixel keyboard placement=below-input")
            } else if aboveY + size.height <= visibleFrame.maxY - 10 {
                y = aboveY
                DebugLog.write("pixel keyboard placement=above-input")
            } else {
                y = min(max(anchor.minY - size.height - 6, visibleFrame.minY + 10), visibleFrame.maxY - size.height - 10)
                DebugLog.write("pixel keyboard placement=clamped-outside")
            }

            origin = NSPoint(x: x, y: y)
        } else {
            screen = NSScreen.screens.first { NSMouseInRect(mouse, $0.frame, false) } ?? NSScreen.main
            origin = NSPoint(x: mouse.x + 8, y: mouse.y - size.height / 2)
        }

        let visibleFrame = screen?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let frame = NSRect(origin: origin, size: size)
        return clamp(frame, to: visibleFrame)
    }

    private func clamp(_ frame: NSRect, to visibleFrame: NSRect) -> NSRect {
        var origin = frame.origin
        origin.x = min(max(origin.x, visibleFrame.minX + 10), visibleFrame.maxX - frame.width - 10)
        origin.y = min(max(origin.y, visibleFrame.minY + 10), visibleFrame.maxY - frame.height - 10)
        return NSRect(origin: origin, size: frame.size)
    }
}

private func fourCharCode(_ text: String) -> OSType {
    var result: UInt32 = 0
    for scalar in text.unicodeScalars.prefix(4) {
        result = (result << 8) + scalar.value
    }
    return result
}

private var appDelegateRef: AppDelegate?

private let hotKeyHandler: EventHandlerUPP = { _, event, _ in
    var hotKeyID = EventHotKeyID()
    GetEventParameter(
        event,
        EventParamName(kEventParamDirectObject),
        EventParamType(typeEventHotKeyID),
        nil,
        MemoryLayout<EventHotKeyID>.size,
        nil,
        &hotKeyID
    )

    if hotKeyID.signature == fourCharCode("sgol"), hotKeyID.id == 1 {
        DebugLog.write("hotkey received; waiting for modifiers to release")
        DispatchQueue.main.async {
            appDelegateRef?.compileSelectedTextAfterDelay(0.35)
        }
    }

    return noErr
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var settingsController: SettingsWindowController?
    private var compilerPromptController: CompilerPromptWindowController?
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private var busy = false
    private let glowHUD = GlowHUDController()
    private var focusedAnchor: NSRect?
    private var targetApplication: NSRunningApplication?

    private var apiKey = ""
    private var baseURL = AppConfig.defaultBaseURL
    private var model = AppConfig.defaultModel
    private var customCompilerPrompt = ""
    private var shortcut = HotKeyShortcut.defaultValue
    private let statusMenuItem = NSMenuItem(title: "Ready", action: nil, keyEquivalent: "")
    private let shortcutMenuItem = NSMenuItem(title: "Shortcut: \(HotKeyShortcut.defaultValue.displayString)", action: nil, keyEquivalent: "")
    private var started = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        start()
    }

    func start() {
        guard !started else { return }
        started = true
        DebugLog.write("app start")
        buildStatusMenu()
        loadSettings()
        let hotKeyRegistered = registerHotKey()
        setStatus(apiKey.isEmpty ? "Set API key first" : "Ready")
        if !hotKeyRegistered {
            setStatus("Shortcut registration failed")
        }
    }

    private func loadSettings() {
        DebugLog.write("loading settings")
        apiKey = UserDefaults.standard.string(forKey: AppConfig.apiKeyDefaultsKey) ?? ""
        baseURL = UserDefaults.standard.string(forKey: AppConfig.baseURLDefaultsKey) ?? AppConfig.defaultBaseURL
        model = UserDefaults.standard.string(forKey: AppConfig.modelDefaultsKey) ?? AppConfig.defaultModel
        customCompilerPrompt = UserDefaults.standard.string(forKey: AppConfig.customCompilerPromptDefaultsKey) ?? ""
        shortcut = HotKeyShortcut.fromDefaults()
        shortcutMenuItem.title = "Shortcut: \(shortcut.displayString)"
        DebugLog.write("settings loaded key=\(!apiKey.isEmpty) baseURL=\(baseURL) model=\(model) customPrompt=\(!customCompilerPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) shortcut=\(shortcut.displayString)")
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
        }
        if let eventHandlerRef {
            RemoveEventHandler(eventHandlerRef)
        }
    }

    private func buildStatusMenu() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        configureStatusButton()

        let menu = NSMenu()
        menu.autoenablesItems = false
        let compileItem = NSMenuItem(title: "Compile Selected Text", action: #selector(compileSelectedText), keyEquivalent: "")
        compileItem.target = self
        compileItem.isEnabled = true
        menu.addItem(compileItem)
        shortcutMenuItem.isEnabled = false
        menu.addItem(shortcutMenuItem)
        menu.addItem(NSMenuItem.separator())
        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)
        menu.addItem(NSMenuItem.separator())
        let accessibilityItem = NSMenuItem(title: "Open Accessibility Settings", action: #selector(openAccessibilitySettings), keyEquivalent: "")
        accessibilityItem.target = self
        accessibilityItem.isEnabled = true
        menu.addItem(accessibilityItem)
        let compilerPromptItem = NSMenuItem(title: "Custom Compiler Prompt...", action: #selector(openCompilerPrompt), keyEquivalent: "")
        compilerPromptItem.target = self
        compilerPromptItem.isEnabled = true
        menu.addItem(compilerPromptItem)
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        settingsItem.isEnabled = true
        menu.addItem(settingsItem)
        let quitItem = NSMenuItem(title: "Quit supergoal", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        quitItem.target = NSApp
        quitItem.isEnabled = true
        menu.addItem(quitItem)
        statusItem.menu = menu
    }

    private func configureStatusButton() {
        guard let button = statusItem.button else { return }
        button.title = ""
        button.toolTip = "supergoal"

        if let url = Bundle.main.url(forResource: "MenuBarIconTemplate", withExtension: "png"),
           let image = NSImage(contentsOf: url) {
            image.isTemplate = true
            image.size = NSSize(width: 18, height: 18)
            button.image = image
            button.imagePosition = .imageOnly
        } else {
            button.title = "SG"
        }
    }

    @discardableResult
    private func registerHotKey() -> Bool {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        var handlerStatus: OSStatus = noErr
        if eventHandlerRef == nil {
            handlerStatus = InstallEventHandler(GetApplicationEventTarget(), hotKeyHandler, 1, &eventType, nil, &eventHandlerRef)
        }

        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }

        let hotKeyID = EventHotKeyID(signature: fourCharCode("sgol"), id: 1)
        let hotKeyStatus = RegisterEventHotKey(shortcut.keyCode, shortcut.modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)

        if handlerStatus == noErr, hotKeyStatus == noErr {
            DebugLog.write("hotkey registered shortcut=\(shortcut.displayString)")
            NSLog("supergoal hotkey registered")
            shortcutMenuItem.title = "Shortcut: \(shortcut.displayString)"
            return true
        } else {
            DebugLog.write("hotkey registration failed handler=\(handlerStatus) hotkey=\(hotKeyStatus)")
            NSLog("supergoal hotkey registration failed handler=%d hotkey=%d", handlerStatus, hotKeyStatus)
            shortcutMenuItem.title = "Shortcut failed: handler \(handlerStatus), hotkey \(hotKeyStatus)"
            setStatus("Shortcut registration failed")
            return false
        }
    }

    @objc func compileSelectedText() {
        compileSelectedTextAfterDelay(0)
    }

    func compileSelectedTextAfterDelay(_ delay: TimeInterval) {
        NSLog("supergoal compile requested")
        DebugLog.write("compile selected requested delay=\(delay)")
        guard !busy else { return }

        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            NSLog("supergoal missing api key")
            DebugLog.write("missing api key")
            setStatus("Open settings and add API key")
            openSettings()
            return
        }

        guard ensureAccessibilityPermission() else {
            NSLog("supergoal accessibility permission missing")
            DebugLog.write("accessibility permission missing")
            setStatus("Grant Accessibility permission")
            return
        }

        busy = true
        targetApplication = NSWorkspace.shared.frontmostApplication
        DebugLog.write("target app=\(targetApplication?.bundleIdentifier ?? "unknown") pid=\(targetApplication?.processIdentifier ?? 0)")
        setStatus("Reading selection...")
        focusedAnchor = focusedElementFrame() ?? targetInputFallbackFrame()

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self else { return }
            self.copySelectionAndCompile()
        }
    }

    private func copySelectionAndCompile() {
        DebugLog.write("copying selection")
        let clipboard = ClipboardSnapshot.capture()
        let beforeCopyChangeCount = NSPasteboard.general.changeCount
        reactivateTargetApplication()
        sendCommandKey(virtualKey: CGKeyCode(kVK_ANSI_C))

        waitForPasteboardString(after: beforeCopyChangeCount, attemptsRemaining: 12) { [weak self] selected in
            guard let self else { return }

            guard !selected.isEmpty else {
                NSLog("supergoal no selected text copied")
                DebugLog.write("no selected text copied")
                clipboard.restore()
                self.busy = false
                self.targetApplication = nil
                self.glowHUD.hide()
                self.setStatus("Select text in Codex first")
                return
            }

            DebugLog.write("selected text copied length=\(selected.count)")
            self.setStatus("Compiling...")
            self.glowHUD.show(stage: "compiling", anchor: self.focusedAnchor)
            let startedAt = Date()
            let compilerPrompt = OpenAIClient.effectiveCompilerPrompt(from: self.customCompilerPrompt)
            DebugLog.write("compiler prompt mode=\(self.customCompilerPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "default" : "custom") length=\(compilerPrompt.count)")
            OpenAIClient.compileSupergoal(
                apiKey: self.apiKey,
                baseURL: self.baseURL,
                model: self.model,
                compilerPrompt: compilerPrompt,
                rawRequest: selected
            ) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let prompt):
                        NSLog("supergoal compile succeeded")
                        DebugLog.write("compile succeeded seconds=\(String(format: "%.2f", Date().timeIntervalSince(startedAt))) promptLength=\(prompt.count)")
                        self.glowHUD.hide {
                            self.replaceSelection(with: prompt, previousClipboard: clipboard)
                        }
                    case .failure(let error):
                        NSLog("supergoal compile failed: %@", error.localizedDescription)
                        DebugLog.write("compile failed: \(error.localizedDescription)")
                        clipboard.restore()
                        self.busy = false
                        self.targetApplication = nil
                        self.glowHUD.hide()
                        self.setStatus(error.localizedDescription)
                    }
                }
            }
        }
    }

    private func waitForPasteboardString(after changeCount: Int, attemptsRemaining: Int, completion: @escaping (String) -> Void) {
        let currentChangeCount = NSPasteboard.general.changeCount
        let text = NSPasteboard.general.string(forType: .string)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if currentChangeCount != changeCount, !text.isEmpty {
            completion(text)
            return
        }

        guard attemptsRemaining > 0 else {
            completion("")
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            self.waitForPasteboardString(after: changeCount, attemptsRemaining: attemptsRemaining - 1, completion: completion)
        }
    }

    private func replaceSelection(with text: String, previousClipboard: ClipboardSnapshot) {
        DebugLog.write("pasting replacement length=\(text.count)")
        setStatus("Pasting...")
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        reactivateTargetApplication()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            self.sendCommandKey(virtualKey: CGKeyCode(kVK_ANSI_V))
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            previousClipboard.restore()
            self.busy = false
            self.targetApplication = nil
            self.glowHUD.hide()
            NSLog("supergoal replacement attempted")
            DebugLog.write("replacement attempted; clipboard restored")
            self.setStatus("Replaced selection")
        }
    }

    private func reactivateTargetApplication() {
        guard let targetApplication else { return }
        DebugLog.write("reactivating target app=\(targetApplication.bundleIdentifier ?? "unknown") pid=\(targetApplication.processIdentifier)")
        if #available(macOS 14.0, *) {
            targetApplication.activate()
        } else {
            targetApplication.activate(options: [.activateIgnoringOtherApps])
        }
    }

    private func focusedElementFrame() -> NSRect? {
        let systemWideElement = AXUIElementCreateSystemWide()
        var focusedElementValue: CFTypeRef?
        guard AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &focusedElementValue) == .success,
              let focusedElementValue else {
            DebugLog.write("focused element frame unavailable")
            return nil
        }

        let focusedElement = focusedElementValue as! AXUIElement
        var positionValue: CFTypeRef?
        var sizeValue: CFTypeRef?
        guard AXUIElementCopyAttributeValue(focusedElement, kAXPositionAttribute as CFString, &positionValue) == .success,
              AXUIElementCopyAttributeValue(focusedElement, kAXSizeAttribute as CFString, &sizeValue) == .success,
              let positionValue,
              let sizeValue else {
            DebugLog.write("focused element position unavailable")
            return nil
        }

        var position = CGPoint.zero
        var size = CGSize.zero
        guard AXValueGetValue(positionValue as! AXValue, .cgPoint, &position),
              AXValueGetValue(sizeValue as! AXValue, .cgSize, &size),
              size.width > 0,
              size.height > 0 else {
            DebugLog.write("focused element frame invalid")
            return nil
        }

        let axFrame = NSRect(origin: position, size: size)
        let converted = appKitFrame(fromAXFrame: axFrame)
        DebugLog.write("focused element frame anchor=\(Int(converted.minX)),\(Int(converted.minY)),\(Int(converted.width)),\(Int(converted.height))")
        return converted
    }

    private func targetInputFallbackFrame() -> NSRect? {
        guard let targetApplication else {
            DebugLog.write("input fallback unavailable: no target app")
            return nil
        }

        guard let windowFrame = targetWindowFrame(for: targetApplication) else {
            DebugLog.write("input fallback unavailable: no target window")
            return nil
        }

        let inputFrame = heuristicInputFrame(in: windowFrame)
        DebugLog.write("input fallback anchor=\(Int(inputFrame.minX)),\(Int(inputFrame.minY)),\(Int(inputFrame.width)),\(Int(inputFrame.height))")
        return inputFrame
    }

    private func targetWindowFrame(for application: NSRunningApplication) -> NSRect? {
        let appElement = AXUIElementCreateApplication(application.processIdentifier)
        var windowValue: CFTypeRef?
        if AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute as CFString, &windowValue) != .success || windowValue == nil {
            var windowsValue: CFTypeRef?
            if AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsValue) == .success,
               let windows = windowsValue as? [AXUIElement],
               let firstWindow = windows.first {
                windowValue = firstWindow
            }
        }

        guard let windowValue else {
            return nil
        }

        let windowElement = windowValue as! AXUIElement
        var positionValue: CFTypeRef?
        var sizeValue: CFTypeRef?
        guard AXUIElementCopyAttributeValue(windowElement, kAXPositionAttribute as CFString, &positionValue) == .success,
              AXUIElementCopyAttributeValue(windowElement, kAXSizeAttribute as CFString, &sizeValue) == .success,
              let positionValue,
              let sizeValue else {
            return nil
        }

        var position = CGPoint.zero
        var size = CGSize.zero
        guard AXValueGetValue(positionValue as! AXValue, .cgPoint, &position),
              AXValueGetValue(sizeValue as! AXValue, .cgSize, &size),
              size.width > 0,
              size.height > 0 else {
            return nil
        }

        return appKitFrame(fromAXFrame: NSRect(origin: position, size: size))
    }

    private func heuristicInputFrame(in windowFrame: NSRect) -> NSRect {
        let sideInset = min(max(windowFrame.width * 0.055, 24), 78)
        let bottomInset = min(max(windowFrame.height * 0.028, 18), 34)
        let inputHeight = min(max(windowFrame.height * 0.115, 76), 132)
        return NSRect(
            x: windowFrame.minX + sideInset,
            y: windowFrame.minY + bottomInset,
            width: max(260, windowFrame.width - sideInset * 2),
            height: inputHeight
        )
    }

    private func appKitFrame(fromAXFrame axFrame: NSRect) -> NSRect {
        let rawCandidate = axFrame
        let convertedCandidate: NSRect
        if let mainScreen = NSScreen.main {
            convertedCandidate = NSRect(
                x: axFrame.minX,
                y: mainScreen.frame.maxY - axFrame.minY - axFrame.height,
                width: axFrame.width,
                height: axFrame.height
            )
        } else {
            convertedCandidate = rawCandidate
        }

        let candidates = [convertedCandidate, rawCandidate]
        for candidate in candidates {
            if NSScreen.screens.contains(where: { candidate.intersects($0.frame) }) {
                return candidate
            }
        }

        return rawCandidate
    }

    private func ensureAccessibilityPermission() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    private func sendCommandKey(virtualKey: CGKeyCode) {
        let source = CGEventSource(stateID: .hidSystemState)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: virtualKey, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: virtualKey, keyDown: false)
        keyDown?.flags = .maskCommand
        keyUp?.flags = .maskCommand
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }

    @objc private func openSettings() {
        DebugLog.write("open settings requested")
        settingsController = SettingsWindowController(
            apiKey: apiKey,
            baseURL: baseURL,
            model: model,
            shortcut: shortcut
        ) { [weak self] key, baseURL, model, shortcut in
            guard let self else { return }
            self.apiKey = key.trimmingCharacters(in: .whitespacesAndNewlines)
            self.baseURL = baseURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? AppConfig.defaultBaseURL : baseURL.trimmingCharacters(in: .whitespacesAndNewlines)
            self.model = model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? AppConfig.defaultModel : model.trimmingCharacters(in: .whitespacesAndNewlines)
            self.shortcut = shortcut

            UserDefaults.standard.set(self.apiKey, forKey: AppConfig.apiKeyDefaultsKey)
            UserDefaults.standard.set(self.baseURL, forKey: AppConfig.baseURLDefaultsKey)
            UserDefaults.standard.set(self.model, forKey: AppConfig.modelDefaultsKey)
            UserDefaults.standard.set(Int(shortcut.keyCode), forKey: AppConfig.shortcutKeyCodeDefaultsKey)
            UserDefaults.standard.set(Int(shortcut.modifiers), forKey: AppConfig.shortcutModifiersDefaultsKey)
            let registered = self.registerHotKey()
            self.setStatus(self.apiKey.isEmpty ? "API key missing" : (registered ? "Settings saved" : "Shortcut registration failed"))
        }

        NSApp.activate(ignoringOtherApps: true)
        settingsController?.showWindow(nil)
        settingsController?.window?.makeKeyAndOrderFront(nil)
        settingsController?.window?.orderFrontRegardless()
        DebugLog.write("settings window shown")
    }

    @objc private func openCompilerPrompt() {
        DebugLog.write("open compiler prompt requested")
        compilerPromptController = CompilerPromptWindowController(customCompilerPrompt: customCompilerPrompt) { [weak self] customCompilerPrompt in
            guard let self else { return }
            self.customCompilerPrompt = customCompilerPrompt
            UserDefaults.standard.set(self.customCompilerPrompt, forKey: AppConfig.customCompilerPromptDefaultsKey)
            self.setStatus(customCompilerPrompt.isEmpty ? "Using default compiler prompt" : "Custom compiler prompt saved")
            DebugLog.write("compiler prompt saved custom=\(!customCompilerPrompt.isEmpty) length=\(customCompilerPrompt.count)")
        }

        NSApp.activate(ignoringOtherApps: true)
        compilerPromptController?.showWindow(nil)
        compilerPromptController?.window?.makeKeyAndOrderFront(nil)
        compilerPromptController?.window?.orderFrontRegardless()
        DebugLog.write("compiler prompt window shown")
    }

    @objc private func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }

    private func setStatus(_ text: String) {
        statusMenuItem.title = text
        statusItem.button?.toolTip = busy ? "supergoal is compiling" : "supergoal"
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
appDelegateRef = delegate
app.setActivationPolicy(.accessory)
app.delegate = delegate
delegate.start()
app.run()
