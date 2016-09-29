//
//  Drawer.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 29/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public struct Drawer: Node {
    public let name: String
    public var content: [String]?
    
    public init(_ name: String, content: [String]? = nil) {
        self.name = name
        self.content = content
    }
    
    public var description: String {
        return "Drawer(name: \(name), content: \(content))"
    }
}

extension OrgParser {
    func lookForDrawers() throws -> [Drawer]? {
        if tokens.isEmpty {
            return nil
        }
        guard case let (meta, .drawerBegin(name)) = tokens.peek()! else {
            return nil
        }
        tokens.takeSnapshot()
        _ = tokens.dequeue()
        var content: [String] = []
        while let (m, token) = tokens.dequeue() {
            if case .drawerEnd = token {
                var result = [Drawer(name, content: content)]
                if let drawers = try lookForDrawers() {
                    result.append(contentsOf: drawers)
                }
                return result
            }
            content.append((m.raw ?? "").trimmed)
        }
        tokens.restore()
        tokens.swapNext(with: (meta, .line(text: (meta.raw?.trimmed)!)))
        return nil
    }
}
