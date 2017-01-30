//
//  Drawer.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 29/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public struct Drawer: Node {
    public let name: String
    public var content: [String]
    
    public init(_ name: String, content: [String] = []) {
        self.name = name
        self.content = content
    }
    
    public var description: String {
        return "Drawer(name: \(name), content: \(content))"
    }
}

extension OrgParser {
    func parseDrawer() throws -> Node? {
        guard case let (meta, Token.drawerBegin(name)) = tokens.dequeue()! else {
            throw Errors.unexpectedToken("drawerBegin expected")
        }
        tokens.takeSnapshot()
        var drawer = Drawer(name)
        var result: Node!
        try lookAhead(match: { token in
            if case .drawerEnd = token { return true }
            return false
        }, found: { token in
            result = drawer
        }, notYet: { tokenMeta in
            drawer.content.append(tokenMeta.raw!)
        }, failed: {
            tokens.restore()
            result = try parseParagraph(meta.raw!)
        })
        return result
    }
}
