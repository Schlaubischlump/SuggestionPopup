//
//  AutocompleteContentView.swift
//  Popup
//
//  Created by David Klopp on 26.12.20.
//

import AppKit

class SuggestionListView: NSScrollView {
    /// The main table view.
    var tableView: NSTableView!
    /// The main table view column.
    var column: NSTableColumn!

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        // Setup the tableView.
        self.tableView = NSTableView(frame: .zero)
        if #available(OSX 11.0, *) {
            self.tableView.style = .fullWidth
        }
        self.tableView.selectionHighlightStyle = NSTableView.SelectionHighlightStyle.regular
        self.tableView.backgroundColor = .clear
        self.tableView.rowSizeStyle = NSTableView.RowSizeStyle.custom
        self.tableView.rowHeight = 36.0
        self.tableView.intercellSpacing = NSSize(width: 5.0, height: 0.0)
        self.tableView.headerView = nil

        // Add a table column.
        self.column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "text"))
        self.column.isEditable = false
        self.tableView.addTableColumn(self.column)

        // Setup the scrollView.
        self.drawsBackground = false
        self.documentView = self.tableView
        self.hasVerticalScroller = true
        self.hasHorizontalScroller = false
        self.automaticallyAdjustsContentInsets = false
        self.contentInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("InitWithCoder not supported.")
    }

    // MARK: - Layout

    override func layout() {
        super.layout()
        self.tableView.frame.size.width = self.frame.width
        self.column.width = self.tableView.frame.width
    }

    // MARK: - Helper

    func selectPreviousRow() {
        let row = self.tableView.selectedRow
        if row > 0 {
            self.tableView.selectRowIndexes([row-1], byExtendingSelection: false)
            self.tableView.scrollRowToVisible(row-1)
        } else {
            self.tableView.selectRowIndexes([], byExtendingSelection: false)
        }
    }

    func selectNextRow() {
        let row = self.tableView.selectedRow
        guard row < self.tableView.numberOfRows-1 else { return }
        self.tableView.selectRowIndexes([row+1], byExtendingSelection: false)
        self.tableView.scrollRowToVisible(row+1)
    }
}
