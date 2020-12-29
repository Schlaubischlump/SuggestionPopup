//
//  AutocompleteMatch.swift
//  Popup
//
//  Created by David Klopp on 26.12.20.
//

import AppKit

public typealias SuggestionSelectAction         = ((String, Suggestion) -> Void)
public typealias SuggestionHighlightAction      = ((String, Suggestion?) -> Void)
public typealias SuggestionShowAction           = (() -> Void)
public typealias SuggestionHideAction           = (() -> Void)
public typealias SuggestionFirstResponderAction = (() -> Void)

/// Your class must conform to this protocol to be displayed in the suggestion list.
public protocol Suggestion: NSObject {
    /// The main title.
    var title: String { get }
    /// The subtitle below the title.
    var subtitle: String { get }
    /// The image to the left.
    var image: NSImage? { get }
    /// Optional range to highlight inside the title.
    var highlightedTitleRanges: [Range<Int>]  { get }
    /// Optional range to highlight inside the subtitle.
    var highlightedSubtitleRanges: [Range<Int>]  { get }
}
