//
//  Section.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 21/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public struct Section: Node {
    public let title: String?
    public let level: Int
    public let state: String?
    public var drawers: [Drawer]?
    
    public var content = [Node]()
    
    public init(level l: Int, title t: String?, todos: [String]) {
        level = l
        
        let pattern = "^(?:(\(todos.joined(separator: "|")))\\s+)?(.*)$"
        if let text = t, let m = text.match(pattern) {
            state = m[1]
            title = m[2]
        } else {
            state = nil
            title = t
        }
    }
    
    public var description: String {
        return "Section(level: \(level), title: \(title), state: \(state))\n - \(drawers)\n - \(content)"
    }
}

extension OrgParser {    
    func parseSection(_ currentLevel: Int = 0) throws -> Node? {
        skipBlanks() // in a section, you don't care about blanks
        
        guard let (_, token) = tokens.peek() else {
            return nil
        }
        switch token {
        case let .headline(l, t):
            if l <= currentLevel {
                return nil
            }
            _ = tokens.dequeue()
            var section = Section(level: l, title: t, todos: document.todos)
            section.drawers = try lookForDrawers()
            while let subSection = try parseSection(l) {
                section.content.append(subSection)
            }
            return section
        case .footnote:
            return try parseFootnote()
        default:
            return try parseTheRest()
        }
    }
}
