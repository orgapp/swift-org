//
//  Nodes.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 22/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public protocol Node: CustomStringConvertible {}

public struct Document: Node {
    public var settings: [String: String]?
    public var nodes: [Node] = []
    
    public var description: String {
        return "Document(settings: \(settings), nodes: \(nodes))"
    }
}

public struct Section: Node {
    public let title: String
    public let level: Int
    public let state: String?
//    public var properties: [String: String] = [:]
    public var nodes: [Node]?
    
    public init(level l: Int, title t: String, state s: String?) {
        level = l
        title = t
        state = s
    }
    
    public var description: String {
        return "Section(level: \(level), title: \(title), state: \(state), nodes: \(nodes))"
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

public struct Line: Node {
    public let text: String
    public var parsed: [InlineToken] {
        return InlineLexer(text: text).tokenize()
    }
    
    public var description: String {
        return "Line(text: \(text))"
    }
}

public struct HorizontalRule: Node {
    public var description: String {
        return "HorizontalRule"
    }
}