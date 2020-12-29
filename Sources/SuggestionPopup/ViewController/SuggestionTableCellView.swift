//
//  AutocompleteTableCellView.swift
//  Popup
//
//  Created by David Klopp on 26.12.20.
//

import AppKit

class SuggestionTableCellView: NSTableCellView {
    /// The cells title.
    var title: String = ""

    /// The cells subtitle.
    var subtitle: String = ""

    /// The cells imageView.
    var image: NSImage? {
        get { self.imageView?.image }
        set { self.imageView?.image = newValue }
    }

    /// The parts of the title to highlight.
    var highlightedTitleRanges: [Range<Int>] = []

    /// The parts of the subtitle to highlight.
    var highlightedSubtitleRanges: [Range<Int>] = []

    /// A reference to the enclosing row view.
    var isHighlighted: Bool = false {
        didSet { self.update() }
    }

    // MARK: - Constructor

    private func setup() {
        // Add the textField
        let textField = NSTextField(frame: .zero)
        textField.isBezeled = false
        textField.drawsBackground = false
        textField.isEditable = false
        textField.isSelectable = false
        textField.maximumNumberOfLines = 2
        self.textField = textField

        // Add the imageViw
        let imageView = NSImageView()
        self.imageView = imageView

        self.addSubview(imageView)
        self.addSubview(textField)
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        self.image = nil
        self.isHighlighted = false
    }

    // MARK: - Layout

    override func layout() {
        super.layout()
        self.update()
    }

    /// Update the title and subtitle text and color.
    func update() {
        // Create a concatenated string with title and subtitle.
        let str = self.title + (self.subtitle.isEmpty ? "" : ("\n" + self.subtitle))
        let mutableAttriStr = NSMutableAttributedString(string: str)

        // The range of the title and subtitle string.
        let titleRange = NSRange(location: 0, length: self.title.count)
        let subtitleRange = NSRange(location: self.title.count + 1, length: self.subtitle.count)
        // The paragraph style to use.
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byTruncatingTail
        // The text color to use.
        let titleFontSize = NSFont.systemFontSize
        let titleColor: NSColor = self.isHighlighted ? .white : .labelColor
        let subtitleFontSize = NSFont.labelFontSize
        let subtitleColor: NSColor = self.isHighlighted ? .white : .secondaryLabelColor

        // Update the attributes string.
        mutableAttriStr.addAttributes([.paragraphStyle:  paragraphStyle,
                                       .font:            NSFont.systemFont(ofSize: titleFontSize),
                                       .foregroundColor: titleColor], range: titleRange)
        mutableAttriStr.addAttributes([.paragraphStyle:  paragraphStyle,
                                       .font:            NSFont.systemFont(ofSize: subtitleFontSize),
                                       .foregroundColor: subtitleColor], range: subtitleRange)

        // Update the title and subtitle highlight.
        self.highlightedTitleRanges.forEach {
            let range = NSMakeRange($0.startIndex, $0.count)
            mutableAttriStr.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: titleFontSize), range: range)
        }
        self.highlightedSubtitleRanges.forEach {
            let range = NSMakeRange(subtitleRange.location + $0.startIndex, $0.count)
            mutableAttriStr.addAttribute(.font, value: NSFont.boldSystemFont(ofSize: subtitleFontSize), range: range)
        }

        // Layout the subviews.
        let pad: CGFloat = 3
        var remainingWidth = self.frame.width
        var frame: CGRect = .zero

        // If the imageView needs to be visible.
        if self.image != nil {
            let size = self.frame.height - pad*2
            frame = CGRect(x: pad, y: pad, width: size, height: size)
            remainingWidth -= frame.maxX
            self.imageView?.frame = frame
        }

        // Center the textField vertically inside the cell
        let textHeight = mutableAttriStr.size().height
        frame = CGRect(x: 0, y: 0, width: remainingWidth, height: textHeight)
        frame.origin.y = (self.frame.height-textHeight)/2.0
        frame.origin.x = self.frame.size.width - remainingWidth + pad
        self.textField?.frame = frame
        // Update the string.
        self.textField?.attributedStringValue = mutableAttriStr
    }
}
