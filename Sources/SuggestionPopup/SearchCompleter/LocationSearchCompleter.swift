//
//  LocationSearchController.swift
//  Popup
//
//  Created by David Klopp on 26.12.20.
//

import AppKit
import MapKit


extension MKLocalSearchCompletion: Suggestion {
    // Highlight the matched string inside the title.
    public var highlightedTitleRanges: [Range<Int>] {
        return self.titleHighlightRanges.compactMap { Range<Int>($0.rangeValue) }
    }

    // Highlight the matched string inside the subtitle.
    public var highlightedSubtitleRanges: [Range<Int>]  {
        return self.subtitleHighlightRanges.compactMap { Range<Int>($0.rangeValue) }
    }

    // We don't show any Image.
    public var image: NSImage? {
        return nil
    }
    
}

/// A simple search completer which searches for locations.
public final class LocationSearchCompleter: SearchCompleter {
    /// Search completer to find a location based on a string.
    private var searchCompleter = MKLocalSearchCompleter()

    // Setup the search completer.
    public override func setup() {
        if #available(OSX 10.15, *) {
            self.searchCompleter.resultTypes = .address
        } else {
            self.searchCompleter.filterType = .locationsOnly
        }
        self.searchCompleter.delegate = self
    }

    // Prepare the search results and show the spinner.
    public override func prepareSuggestions(for searchString: String) {
        // Show a progress spinner.
        self.showSpinner()
        // Cancel any running search request.
        if self.searchCompleter.isSearching {
            self.searchCompleter.cancel()
        }
        // Start a search.
        self.searchCompleter.queryFragment = searchString
    }

    // Show the results and hide the spinner.
    public override func setSuggestions(_ suggestions: [Suggestion]) {
        self.hideSpinner()
        super.setSuggestions(suggestions)
    }
}

extension LocationSearchCompleter: MKLocalSearchCompleterDelegate {
    /// Called when the searchCompleter finished loading the search results.
    public func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.setSuggestions(self.searchCompleter.results)
    }
}
