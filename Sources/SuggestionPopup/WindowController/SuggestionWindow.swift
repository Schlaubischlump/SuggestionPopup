//
//  AutocompleteWindow.swift
//  Popup
//
//  Created by David Klopp on 26.12.20.
//

import AppKit

class SuggestionWindow: NSWindow {

    // MARK: - Constructor

    /// Create a bordless, transparent window which hosts the popup.
    init() {
        super.init(contentRect: .zero, styleMask: .borderless, backing: .buffered, defer: true)
        // Configure the window
        self.hasShadow = true
        self.backgroundColor = .clear
        self.isOpaque = false
        self.isMovable = false
        self.isMovableByWindowBackground = false
        // Assign the contentViewController.
        self.contentViewController = SuggestionListViewController()
    }

    // MARK: - Spinner

    func showSpinner() {
        // Use a fixed height.
        var size = self.frame.size
        size.height = 40
        self.setContentSize(size)
        let contentViewController = self.contentViewController as? SuggestionListViewController
        contentViewController?.showSpinner()
    }

    func hideSpinner() {
        let contentViewController = self.contentViewController as? SuggestionListViewController
        contentViewController?.hideSpinner()
    }

    // MARK: - Results

    func setSuggestions(_ suggestions: [Suggestion]) {
        let contentViewController = self.contentViewController as? SuggestionListViewController
        // Update the results.
        contentViewController?.setSuggestions(suggestions)
        // Update the content size.
        let contentSize = contentViewController?.getSuggestedWindowSize() ?? .zero
        let bottomLeftPoint = CGPoint(x: self.frame.minX, y: self.frame.maxY - contentSize.height)
        self.setFrame(CGRect(origin: bottomLeftPoint, size: contentSize), display: true)
    }
}

// MARK: - Accessibility
extension SuggestionWindow {
    /// We ignore this window for accessibility.
    override func isAccessibilityElement() -> Bool {
        return false
    }
}
