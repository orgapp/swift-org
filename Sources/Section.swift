//
//  Section.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 21/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public struct Section: Node {
    
    // MARK: properties
    public var index: OrgIndex?

    public var title: String?
    public var stars: Int
    public var keyword: String?
    public var priority: Priority?
    public var tags: [String]?
    public var content = [Node]()
    
    public var drawers: [Drawer]? {
        let ds = content.filter { node in
            return node is Drawer
            }.map { node in
                return node as! Drawer
        }
        return ds
    }
    
    public var planning: Planning? {
        return content.first { $0 is Planning } as? Planning
    }
    
    // MARK: func
    public init(stars l: Int, title t: String?, todos: [String]) {
        stars = l
        // TODO limit charset on tags
        let pattern = "^(?:(\(todos.joined(separator: "|")))\\s+)?(?:\\[#([ABCabc])\\]\\s+)?(.*?)(?:\\s+((?:\\:.+)+\\:)\\s*)?$"
        if let text = t, let m = text.match(pattern) {
            keyword = m[1]
            if let p = m[2] {
                priority = Priority(rawValue: p.uppercased())
            }
            title = m[3]
            if let t = m[4] {
                tags = t.components(separatedBy: ":").filter({ !$0.isEmpty })
            }
        } else {
            title = t
        }
    }
    
    public var description: String {
        return "Section[\(index)](stars: \(stars), keyword: \(keyword)), priority: \(priority)), title: \(title)\n - tags: \(tags)\n - \(drawers)\n - \(content)"
    }
}

public struct Planning: Node {
    public let keyword: PlanningKeyword
    public let timestamp: Timestamp?
    
    public var description: String {
        return "Planning(keyword: \(keyword), timestamp: \(timestamp))"
    }
}

extension OrgParser {    
    func parseSection(_ index: OrgIndex) throws -> Node? {
        skipBlanks() // in a section, you don't care about blanks
        
        guard let (_, token) = tokens.peek() else {
            return nil
        }
        switch token {
        case let .headline(l, t):
            if l < index.indexes.count {
                return nil
            }
            _ = tokens.dequeue()
            var section = Section(stars: l, title: t, todos: document.todos.flatMap{ $0 })
            section.index = index
            var subIndex = index.in
            while let subSection = try parseSection(subIndex) {
                section.content.append(subSection)
                subIndex = subIndex.next
            }
            return section
        case .footnote:
            return try parseFootnote()
        default:
            return try parseTheRest()
        }
    }
}
