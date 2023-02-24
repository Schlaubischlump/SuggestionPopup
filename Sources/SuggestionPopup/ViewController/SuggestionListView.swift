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

    /// Always force overlay style, even on 10.15.x, 11.x and 12.x
    override var scrollerStyle: NSScroller.Style {
        get { return .overlay }
        set { }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        // Setup the tableView.
        self.tableView = NSTableView(frame: .zero)
        var insetBottom: CGFloat = 5
        if #available(OSX 11.0, *) {
            self.tableView.style = .inset
            insetBottom = 0
        } else if #available(OSX 13.0, *) {
            self.tableView.style = .inset
            insetBottom = 10
        }

        self.tableView.selectionHighlightStyle = .regular
        self.tableView.backgroundColor = .clear
        self.tableView.rowSizeStyle = .custom
        self.tableView.rowHeight = 36.0
        self.tableView.intercellSpacing = NSSize(width: 5.0, height: 0.0)
        self.tableView.headerView = nil

        // Add a table column.
        self.column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "text"))
        self.column.isEditable = false
        self.tableView.addTableColumn(self.column)

        // Setup the scrollView.
        self.documentView = self.tableView

        self.drawsBackground = false
        self.hasVerticalScroller = true
        self.hasHorizontalScroller = false
        //self.verticalScroller?.controlSize = .small
        self.automaticallyAdjustsContentInsets = false
        self.contentInsets = NSEdgeInsets(top: 0, left: 0, bottom: insetBottom, right: 0)
        self.scrollerInsets = NSEdgeInsets(top: 0, left: 0, bottom: -insetBottom, right: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("InitWithCoder not supported.")
    }

    // MARK: - Layout

    /// Not required for macOS 10.13 and up
    override func layout() {
        super.layout()
        let width = self.frame.width
        // fix size on macOS Big Sur
        self.tableView.sizeToFit()
        self.tableView.frame.size.width = width
        self.contentView.frame.size.width = width
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
