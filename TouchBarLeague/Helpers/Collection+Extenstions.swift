//
//  Collection+Extenstions.swift
//  TouchBarLeague
//
//  Created by Marcin Slusarek on 16/05/2019.
//  Copyright © 2019 Marcin Slusarek. All rights reserved.
//

import Foundation
import AppKit

extension Collection where Element: Equatable {
    var orderedSet: [Element]  {
        var array: [Element] = []
        return compactMap {
            if array.contains($0) {
                return nil
            } else {
                array.append($0)
                return $0
            }
        }
    }
}

extension NSImage {
    func resized(to: CGSize) -> NSImage {
        let img = NSImage(size: to)
        
        img.lockFocus()
        defer {
            img.unlockFocus()
        }
        
        if let ctx = NSGraphicsContext.current {
            ctx.imageInterpolation = .high
            draw(in: NSRect(origin: .zero, size: to),
                 from: NSRect(origin: .zero, size: size),
                 operation: .copy,
                 fraction: 1)
        }
        
        return img
    }
}
