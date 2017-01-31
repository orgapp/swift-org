//
//  OrgDocument.swift
//  SwiftOrg
//
//  Created by Xiaoxing Hu on 21/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public struct OrgDocument: Node {
    public var settings = [String: String]()
    public var content = [Node]()
    
    public var title: String? {
        return settings["TITLE"]
    }
    
    public let defaultTodos: [[String]]
    
    public var todos: [[String]] {
        if let todo = settings["TODO"] {
            let keywords = todo.components(separatedBy: .whitespaces)
            var result: [[String]] = [[]]
            for keyword in keywords {
                if keyword == "|" {
                    result.append([])
                } else {
                    result[result.endIndex - 1].append(keyword)
                }
            }
            return result
        }
        return defaultTodos
    }
    
    public init(todos: [[String]]) {
        defaultTodos = todos
    }
    
    public var description: String {
        return "OrgDocument(settings: \(settings))\n - \(content)"
    }
}

extension OrgParser {
    func parseDocument() throws -> OrgDocument {
        var index = OrgIndex([0])
        while let (_, token) = tokens.peek() {
            switch token {
            case let .setting(key, value):
                _ = tokens.dequeue()
                document.settings[key] = value
            default:
                if let node = try parseSection(index) {
                    document.content.append(node)
                    index = index.next
                }
            }
        }
        return document
    }
}
