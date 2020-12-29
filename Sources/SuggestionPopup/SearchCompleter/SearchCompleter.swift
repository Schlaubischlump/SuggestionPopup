//
//  AutocompleteSearchController.swift
//  Popup
//
//  Created by David Klopp on 26.12.20.
//

// TODO:
// Bug 2: Sometimes the text entry is broken when removing characters
// Bug 3: Hovering over a cell while deleting breaks the deleting mechanism. (This is the same as bug 2)

import AppKit

open class SearchCompleter: NSObject, KeyResponder {
    /// The main searchField instance.
    public weak var searchField: NSTextField!

    /// Window events.
    public var onShow: SuggestionShowAction?
    public var onHide: SuggestionHideAction?
    public var onSelect: SuggestionSelectAction?
    public var onHighlight: SuggestionHighlightAction? {
        get { return self.windowController.onHighlight }
        set { self.windowController.onHighlight = newValue }
    }

    /// The main window controller.
    var windowController: SuggestionWindowController!

    /// A reference to the textDidChange observer.
    private var textDidChangeObserver: NSObjectProtocol?

    /// A reference to the window didResignKey observer.
    private var lostFocusObserver: Any?

    /// The internal monitor to capture key events.
    private var localKeyEventMonitor: Any?

    /// The internal monitor to capture mouse events.
    private var localMouseDownEventMonitor: Any?

    // MARK: - Constructor

    public init(searchField: NSTextField) {
        super.init()
        self.searchField = searchField
        self.windowController = SuggestionWindowController(searchField: searchField)
        self.setup()

        // Listen for text changes inside the textField.
        self.registerTextFieldNotifications()
        self.registerFocusNotifications()

        // Add and remove the key and mouse events depending on whether the window is visible.
        self.windowController.onShow = { [weak self] in
            self?.registerKeyEvents()
            self?.registerMouseEvents()
            self?.onShow?()
        }
        self.windowController.onHide = { [weak self] in
            self?.unregisterKeyEvents()
            self?.unregisterMouseEvents()
            self?.onHide?()
        }
        self.windowController.onSelect = { [weak self] in
            self?.windowController.hide()
            self?.onSelect?($0, $1)
        }
    }

    // MARK: - Destructor

    deinit {
        self.unregisterTextFieldNotifications()
        self.unregisterFocusNotifications()
    }

    // MARK: - KeyEvents

    /// Handle key up and down events.
    private func registerKeyEvents() {
        self.localKeyEventMonitor = NSEvent.addLocalMonitorForEvents(
            matching: [.keyDown, .keyUp]) { [weak self] (event) -> NSEvent? in
            // If the current searchField is the first responder, we capture the event.
            guard let firstResponder = self?.searchField?.window?.firstResponder else { return event }
            if firstResponder == self?.searchField.currentEditor() {
                return self?.processKeys(with: event)
            }
            return event
        }
    }

    /// Remove the key event monitor.
    private func unregisterKeyEvents() {
        if let eventMonitor = self.localKeyEventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
        self.localKeyEventMonitor = nil
    }

    /// Return the event, to allow other classes to handle the event or nil to capture it.
    func processKeys(with theEvent: NSEvent) -> NSEvent? {
        // Check if this controller can handle the event.
        if let keyEvent = KeyCodes(rawValue: theEvent.keyCode) {
            switch keyEvent {
            case .return:
                // Hide the window.
                self.windowController.hide()
            case .tab:
                // Do not capture the tab event. We still want to be able to change the focus.
                self.windowController.hide()
            default:
                break
            }
        }
        // Check if the window controller can handle the event.
        return self.windowController != nil ? self.windowController?.processKeys(with: theEvent) : theEvent
    }

    // MARK: - Mouse Events

    /// Handle mouse clickes inside and outside the window.
    private func registerMouseEvents() {
        self.localMouseDownEventMonitor = NSEvent.addLocalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown, .otherMouseDown]) { [weak self] (event) -> NSEvent? in
            // Make sure the event has a window.
            guard let eventWindow = event.window, let window = self?.windowController.window else { return event }
            let isSuggestionWindow       = eventWindow == window
            let clickedInsideContentView = eventWindow.contentView?.hitTest(event.locationInWindow) != nil
            let clickedInsideTextField   = self?.searchField.hitTest(event.locationInWindow) != nil

            // If the event window was clicked outside its toolbar then dismiss the popup.
            if !isSuggestionWindow && clickedInsideContentView && !clickedInsideTextField {
                self?.windowController.hide()
            }
            return event
        }
    }

    /// Remove the mouse click monitor.
    private func unregisterMouseEvents() {
        if let eventMonitor = self.localMouseDownEventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
        self.localMouseDownEventMonitor = nil
    }

    // MARK: - TextField

    private func registerTextFieldNotifications() {
        self.textDidChangeObserver = NotificationCenter.default.addObserver(
            forName: NSTextField.textDidChangeNotification,
            object: self.searchField, queue: .main) { [weak self] _ in

            let text = self?.searchField.stringValue ?? ""
            if text.isEmpty {
                // Hide window
                self?.windowController.hide()
            } else {
                self?.prepareSuggestions(for: text)
                // Show the autocomplete window and start a progress spinner.
                self?.windowController.show()
            }
        }
    }

    private func unregisterTextFieldNotifications() {
        if let observer = self.textDidChangeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        self.textDidChangeObserver = nil
    }

    // MARK: - Focus

    private func registerFocusNotifications() {
        // If the suggestion window looses focus we dismiss it.
        guard let window = self.windowController.window else { return }
        self.lostFocusObserver = NotificationCenter.default.addObserver(forName: NSWindow.didResignKeyNotification,
                                                                        object: window,
                                                                        queue: nil) { [weak self] _ in
            self?.windowController.hide()
        }
    }

    private func unregisterFocusNotifications() {
        if let observer = self.lostFocusObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        self.lostFocusObserver = nil
    }

    // MARK: - Public Methods

    /// Show the spinner to indicate work.
    public func showSpinner() {
        let window = self.windowController.window as? SuggestionWindow
        window?.showSpinner()
    }

    /// Hide the spinner to indicate the work is finished.
    public func hideSpinner() {
        let window = self.windowController.window as? SuggestionWindow
        window?.hideSpinner()
    }

    // MARK: - Override

    /// Override this function to perform initial setup.
    open func setup() {

    }

    /// This function is called when the textField text changes. Prepare your search results here.
    open func prepareSuggestions(for searchString: String) {

    }

    /// Use this function to update the search results.
    open func setSuggestions(_ suggestions: [Suggestion]) {
        self.windowController.setSuggestions(suggestions)
        // If we don't have any suggestions hide the window.
        if suggestions.isEmpty {
            self.windowController.hide()
        }
    }
}
