//
//  AutocompleteContentViewController.swift
//  Popup
//
//  Created by David Klopp on 26.12.20.
//

import AppKit

let kMaxResults = 5
let kCellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "AutocompleteCell")

class SuggestionListViewController: NSViewController, KeyResponder {
    /// The main tableView with all search results.
    var contentView: SuggestionListView!
    /// The list with all suggestions.
    var suggestions: [Suggestion] = []
    /// The progress spinner when loading results.
    private var spinner: NSProgressIndicator!
    /// The target and action to perform when a cell is selected.
    var target: AnyObject?
    var action: Selector?

    /// Override loadView to load our custom content view.
    override func loadView() {
        // Create a container view that contains the effect view and the content view.
        let containerView = NSView()

        // Add the effect view.
        let effectView = NSVisualEffectView(frame: containerView.bounds)
        effectView.autoresizingMask = [.height, .width]
        effectView.isEmphasized = false
        effectView.state = .active
        if #available(OSX 10.14, *) {
            effectView.material = .underWindowBackground
        } else {
            effectView.material = .titlebar
        }
        effectView.blendingMode = .behindWindow
        containerView.addSubview(effectView)

        // Add the content view.
        self.contentView = SuggestionListView(frame: containerView.bounds)
        self.contentView.autoresizingMask = [.height, .width]
        self.contentView.isHidden = false
        self.contentView.tableView.dataSource = self
        self.contentView.tableView.delegate = self
        containerView.addSubview(contentView)

        // Handle the tableView click events.
        self.contentView.tableView.target = self
        self.contentView.tableView.action = #selector(performActionForSelectedCell(_:))

        // Add the progress spinner.
        self.spinner = NSProgressIndicator(frame: .zero)
        self.spinner.style = .spinning
        self.spinner.isHidden = true
        containerView.addSubview(self.spinner)

        // Apply a corner radius to the view.
        containerView.wantsLayer = true
        containerView.layer?.cornerRadius = 5.0

        self.view = containerView
    }

    override func viewDidLayout() {
        super.viewDidLayout()
        // Update the spinner. Autoresizing is not powerfull enough.
        let pad: CGFloat = 8.0
        let size = self.view.bounds.height - pad*2
        self.spinner.frame = CGRect(x: pad, y: pad, width: size, height: size)
    }

    // MARK: - Spinner

    func showSpinner() {
        self.spinner.startAnimation(nil)
        self.spinner.isHidden = false
        self.contentView.isHidden = true
    }

    func hideSpinner() {
        self.spinner.stopAnimation(nil)
        self.spinner.isHidden = true
        self.contentView.isHidden = false
    }

    // MARK: - Results

    func setSuggestions(_ suggestions: [Suggestion]) {
        self.suggestions = suggestions
        self.contentView.tableView.reloadData()
    }

    // MARK: - Helper

    /// Get the current suggested content size.
    func getSuggestedWindowSize() -> CGSize {
        guard let tableView = self.contentView.tableView else { return .zero }

        let numberOfRows = min(tableView.numberOfRows, kMaxResults)
        let rowHeight = tableView.rowHeight
        let spacing = tableView.intercellSpacing
        var frame = self.view.frame
        frame.size.height = (rowHeight + spacing.height) * CGFloat(numberOfRows)
        return frame.size
    }

    // MARK: - Key events

    func processKeys(with theEvent: NSEvent) -> NSEvent? {
        let keyUp: Bool = theEvent.type == .keyUp

        if let keyEvent = KeyCodes(rawValue: theEvent.keyCode) {
            switch keyEvent {
            case .arrowUp:
                if !keyUp {
                    self.contentView.selectPreviousRow()
                }
                // Capture this event.
                return nil
            case .arrowDown:
                if !keyUp {
                    self.contentView.selectNextRow()
                }
                // Capture this event.
                return nil
            case .return:
                // Perform the action for the currently selected cell.
                self.performActionForSelectedCell()
                return nil
            default:
                break
            }
        }

        return theEvent
    }

    // MARK: - Click 

    @objc func performActionForSelectedCell(_ sender: AnyObject? = nil) {
        let selectedRow = self.contentView.tableView.selectedRow
        if selectedRow >= 0 && selectedRow < self.suggestions.count {
            let suggestion = self.suggestions[selectedRow]
            _  = self.target?.perform(self.action, with: suggestion)
        }
    }
}


extension SuggestionListViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.suggestions.count
    }
}

extension SuggestionListViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return SuggestionTableRowView(tableView: tableView, row: row)
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var cellView = tableView.makeView(withIdentifier: kCellIdentifier, owner: self) as? SuggestionTableCellView
        if cellView == nil {
            let cellFrame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.rowHeight)
            cellView = SuggestionTableCellView(frame: cellFrame)
            cellView?.identifier = kCellIdentifier
        }
        // Assign the new values and update the cell.
        cellView?.image = self.suggestions[row].image
        cellView?.title = self.suggestions[row].title
        cellView?.subtitle = self.suggestions[row].subtitle
        cellView?.highlightedTitleRanges = self.suggestions[row].highlightedTitleRanges
        cellView?.highlightedSubtitleRanges = self.suggestions[row].highlightedSubtitleRanges
        cellView?.update()

        return cellView
    }
}
