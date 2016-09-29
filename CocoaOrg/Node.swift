//
//  Nodes.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 22/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public protocol Node: CustomStringConvertible {}

extension OrgParser {
    func parseTheRest() throws -> Node? {
        guard let (_, token) = tokens.peek() else {
            return nil
        }
        switch token {
        case .blank:
            _ = tokens.dequeue()
            return nil
        case .line:
            return try parseParagraph()
        case let .comment(t):
            _ = tokens.dequeue()
            return Comment(text: t)
        case .blockBegin:
            return try parseBlock()
        case .listItem:
            return try parseList()
        case .drawerBegin, .drawerEnd:
            _ = tokens.dequeue() // discard non-functional drawers
            return nil
        default:
            throw Errors.unexpectedToken("\(token) is not expected")
        }
    }
}
