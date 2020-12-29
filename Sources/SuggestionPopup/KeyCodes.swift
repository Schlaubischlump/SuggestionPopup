//
//  KeyCodes.swift
//  Popup
//
//  Created by David Klopp on 27.12.20.
//

import AppKit

enum KeyCodes: UInt16 {
    case `return`   = 36
    case tab        = 48
    case arrowLeft  = 123
    case arrowRight = 124
    case arrowDown  = 125
    case arrowUp    = 126
}

/// Define a class to be able to handle key events.
protocol KeyResponder {
    func processKeys(with theEvent: NSEvent) -> NSEvent?
}
