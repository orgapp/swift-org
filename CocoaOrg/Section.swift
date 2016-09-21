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
