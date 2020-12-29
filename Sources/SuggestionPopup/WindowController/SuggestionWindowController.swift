//
//  AutoCompleteWindowController.swift
//  Popup
//
//  Created by David Klopp on 26.12.20.
//
import AppKit

class SuggestionWindowController: NSWindowController, KeyResponder {
    /// The textfield instance to manage.
    private weak var searchField: NSTextField!

    /// A referenc to the searchFields parent window.
    private var parentWindow: NSWindow? { return self.searchField.window }

    /// The currently entered search query.
    private var searchQuery: String = ""

    /// A reference to the textDidChange observer.
    private var textDidChangeObserver: NSObjectProtocol?

    /// A reference to the tableView selection change observer.
    private var selecionChangedObserver: NSObjectProtocol?

    /// Callback handlers.
    var onShow:      SuggestionShowAction?
    var onHide:      SuggestionHideAction?
    var onHighlight: SuggestionHighlightAction?
    var onSelect:    SuggestionSelectAction?

    // MARK: - Constructor

    init(searchField: NSTextField) {
        self.searchField = searchField
        let window = SuggestionWindow()
        window.hidesOnDeactivate = false

        super.init(window: window)

        // Handle the cell selection.
        let contentViewController = self.contentViewController as? SuggestionListViewController
        contentViewController?.target = self
        contentViewController?.action = #selector(self.selectedSuggestion(_:))

        // Listen for text changes inside the textField.
        self.registerNotifications()
    }


    // MARK: - Destructor

    deinit {
        if let observer = self.textDidChangeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = self.selecionChangedObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        self.textDidChangeObserver = nil
        self.selecionChangedObserver = nil
    }

    // MARK: - TextField

    private func registerNotifications() {
        let center = NotificationCenter.default

        self.textDidChangeObserver = center.addObserver(forName: NSTextField.textDidChangeNotification,
                                                        object: self.searchField,
                                                        queue: .main) { [weak self] _ in
            // Save the current search query.
            self?.searchQuery = self?.searchField.stringValue ?? ""
        }

        // Listen for tableView cell highlighting.
        guard let contentViewController = self.contentViewController as? SuggestionListViewController else {
            return
        }
        let tableView = contentViewController.contentView.tableView
        self.selecionChangedObserver = center.addObserver(forName: NSTableView.selectionDidChangeNotification,
                                                          object: tableView,
                                                          queue: .main) { [weak self] notification in
            guard let row = tableView?.selectedRow, let queryString = self?.searchQuery else { return }

            let editor = self?.searchField.currentEditor() as? NSTextView
            var suggestion: Suggestion?
            if row >= 0 {
                // Cell selected, display the suggestion.
                suggestion = contentViewController.suggestions[row]
                let title = suggestion!.title

                // If the search string matches the start of the title, highlight the remaining part,
                // otherwise highlight the complete title.
                self?.searchField.stringValue = title
                let range = NSMakeRange(title.starts(with: queryString) ? queryString.count : 0, title.count)
                editor?.setSelectedRange(range)

            } else {
                // Cell was deselected. Reset the search query and clear the seletion.
                self?.searchField.stringValue = queryString
                editor?.moveToEndOfLine(nil)
            }
            self?.onHighlight?(queryString, suggestion)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("InitWithCoder not supported.")
    }

    // MARK: - Selection

    @objc private func selectedSuggestion(_ suggestion: AnyObject) {
        guard let suggestion = suggestion as? Suggestion else { return }
        self.onSelect?(self.searchQuery, suggestion)
    }

    // MARK: - Show / Hide

    /// Show the window.
    /// - Return: True if the window can be shown, false otherwise.
    @discardableResult
    func show() -> Bool {
        // Make sure the searchField is inside the view hierachy.
        guard let window = self.window, !window.isVisible,
              let parentWindow = self.parentWindow,
              let searchFieldParent = self.searchField.superview else { return false }
        // The window has the same width as the searchField.
        var frame = window.frame
        frame.size.width = self.searchField.frame.width
        // Position the window directly below the searchField.
        var location = searchFieldParent.convert(self.searchField.frame.origin, to: nil)
        location = parentWindow.convertToScreen(CGRect(x: location.x, y: location.y, width: 0, height: 0)).origin
        location.y -= 5
        // Apply the frame and position.
        window.setContentSize(frame.size)
        window.setFrameTopLeftPoint(location)
        // Show the window
        parentWindow.addChildWindow(window, ordered: .above)
        self.onShow?()
        return true
    }

    /// Hide the window.
    @discardableResult
    func hide() -> Bool {
        guard let window = self.window, window.isVisible else { return false }
        window.parent?.removeChildWindow(window)
        window.orderOut(nil)
        self.onHide?()
        return true
    }

    // MARK: - Results

    func setSuggestions(_ suggestions: [Suggestion]) {
        guard let window = self.window as? SuggestionWindow else { return }
        window.setSuggestions(suggestions)
    }

    // MARK: - Key Events

    /// Return the event, to allow other classes to handle the event or nil to capture it.
    func processKeys(with theEvent: NSEvent) -> NSEvent? {
        // Check if the window's contentViewController can handle the event.
        let viewController = self.contentViewController as? KeyResponder
        return viewController != nil ? viewController?.processKeys(with: theEvent) : theEvent
    }
}
