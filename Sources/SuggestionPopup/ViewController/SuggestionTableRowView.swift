//
//  AutoCompleteTableRowView.swift
//  Popup
//
//  Created by David Klopp on 27.12.20.
//

import AppKit

class SuggestionTableRowView: NSTableRowView {
    /// Reference to the parent table view.
    weak var tableView: NSTableView?
    /// The row number.
    var row: Int

    /// Inform the cell if it should be highlighted.
    override var isSelected: Bool {
        didSet {
            guard self.numberOfColumns > 0 else { return }
            // Update the cells highlight state.
            let cellView = self.view(atColumn: 0) as? SuggestionTableCellView
            cellView?.isHighlighted = self.isSelected
        }
    }

    /// Always use a blue highlight for the cells.
    override var isEmphasized: Bool {
        get { return true }
        set {}
    }

    // MARK: - Constructor

    init(tableView: NSTableView, row: Int) {
        self.tableView = tableView
        self.row = row
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("InitWithCoder not available.")
    }

    // MARK: - Hover

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        // Define the traking area to execute the mouseEntered and mouseExited events.
        for trackingArea in self.trackingAreas {
            self.removeTrackingArea(trackingArea)
        }
        let options: NSTrackingArea.Options = [.mouseMoved, .mouseEnteredAndExited, .activeInActiveApp]
        let trackingArea = NSTrackingArea(rect: self.bounds, options: options, owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
    }

    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        self.tableView?.selectRowIndexes([row], byExtendingSelection: false)
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        self.tableView?.selectRowIndexes([], byExtendingSelection: false)
    }
}
