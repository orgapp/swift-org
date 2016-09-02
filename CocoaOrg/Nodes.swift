//
//  Nodes.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 22/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public protocol Node: CustomStringConvertible {}

public typealias OrgNode = TreeNode<Node>

public struct DocumentMeta: Node {
    public var settings = [String: String]()
    
    public var title: String {
        return settings["TITLE"] ?? ""
    }
    
    public var todos: [String] {
        var todos = ["TODO", "DONE"]
        if let todo = settings["TODO"] {
            todos.append(todo)
        }
        return todos
    }
    
    public var description: String {
        return "Document(settings: \(settings))"
    }
}

public struct Section: Node {
    public let title: String
    public let level: Int
    public let state: String?
//    public var properties: [String: String] = [:]
    
    public init(level l: Int, title t: String, todos: [String]) {
        level = l
        
        let pattern = "^(?:(\(todos.joinWithSeparator("|")))\\s+)?(.*)$"
        if let m = t.match(pattern) {
            state = m[1]
            title = m[2]!
        } else {
            state = nil
            title = t
        }
    }
    
    public var description: String {
        return "Section(level: \(level), title: \(title), state: \(state))"
    }
}

public struct Block: Node {
    public let type: String
    public let params: [String]?
    public var content: [String] = []
    
    public init(type t: String, params p: [String]? = nil) {
        type = t
        params = p
    }
    
    public var description: String {
        return "Block(type: \(type), params: \(params), content: \(content))"
    }
}

public struct Comment: Node {
    public let text: String?
    
    public var description: String {
        return "Comment(text: \(text))"
    }
}

public struct ListItem: Node {
    public let text: String
 
    public var description: String {
        return "ListItem(text: \(text))"
    }
}

public struct List: Node {
    public let items: [ListItem]
    public let ordered: Bool

    public var description: String {
        return "List(ordered: \(ordered), items: \(items))"
    }
}

public struct Blank: Node {
    public var description: String {
        return "Blank"
    }
}

public struct Paragraph: Node {
    public var lines: [String]
    public var text: String {
        return lines.joinWithSeparator(" ")
    }
    public var parsed: [InlineToken] {
        return InlineLexer(text: text).tokenize()
    }
    
    public var description: String {
        return "Paragraph(text: \(text))"
    }
}

public struct HorizontalRule: Node {
    public var description: String {
        return "HorizontalRule"
    }
}
