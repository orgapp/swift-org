//
//  Parser.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 22/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public enum Errors: ErrorType {
    case UnexpectedToken(String)
}

public class Parser {
    // MARK: properties
    var tokens: Queue<Token>
    
    // MARK: init
    public init(tokens: [Token]) {
        self.tokens = Queue<Token>(data: tokens)
    }
    
    public convenience init(lines: [String]) throws {
        let lexer = Lexer(lines: lines)
        self.init(tokens: try lexer.tokenize())
    }
    
    public convenience init(content: String) throws {
        try self.init(lines: content.lines)
    }
    
    // MARK: Greater Elements
    func parseBlock() throws -> Node {
        guard case let Token.BlockBegin(meta, type, params) = tokens.dequeue()! else {
            throw Errors.UnexpectedToken("BlockBegin expected")
        }
        var block = Block(type: type, params: params)
        tokens.takeSnapshot()
        while let token = tokens.dequeue() {
            switch token {
            case let .BlockEnd(_, t):
                if t.lowercaseString != type.lowercaseString {
                    throw Errors.UnexpectedToken("Expecting BlockEnd of type \(type), but got \(t)")
                }
                return block
            default:
                block.content.append(token.meta.raw ?? "")
            }
        }
        tokens.restore()
        return try self.parseLines(meta.raw?.trimmed)
    }
    
    func parseList() throws -> List {
        guard case let Token.ListItem(_, indent, text, ordered) = tokens.dequeue()! else {
            throw Errors.UnexpectedToken("ListItem expected")
        }
        var list = List(ordered: ordered)
        list.items = [ListItem(text: text)]
        while let token = tokens.peek() {
            if case let .ListItem(_, i, t, _) = token {
                if i > indent {
                    var lastItem = list.items.removeLast()
                    lastItem.list = try parseList()
                    list.items += [lastItem]
                } else if i == indent {
                    tokens.dequeue()
                    list.items += [ListItem(text: t)]
                } else {
                    break
                }
            } else {
                break
            }
        }
        
        return list
    }
    
    func parseLines(startWith: String? = nil) throws -> Paragraph {
        guard case Token.Line(_, let text) = tokens.dequeue()! else {
            throw Errors.UnexpectedToken("Line expected")
        }
        var line = Paragraph(lines: [text])
        if let firstLine = startWith {
            line.lines.insert(firstLine, atIndex: 0)
        }
        while let token = tokens.peek() {
            if case .Line(_, let t) = token {
                line.lines.append(t)
                tokens.dequeue()
            } else {
                break
            }
        }
        return line
    }
    
    
    func parseSection(parent: OrgNode) throws {
        while let token = tokens.peek() {
            switch token {
            case let .Header(_, l, t):
                if l <= getCurrentLevel(parent) {
                    return
                }
                tokens.dequeue()
                let subSection = parent.add(Section(
                    level: l, title: t, todos: getTodos(parent)))
                try parseSection(subSection)
            case .Blank:
                tokens.dequeue()
                parent.add(Blank())
            case .Line:
                parent.add(try parseLines())
            case let .Comment(_, t):
                tokens.dequeue()
                parent.add(Comment(text: t))
            case .BlockBegin:
                parent.add(try parseBlock())
            case .ListItem:
                parent.add(try parseList())
            default:
                throw Errors.UnexpectedToken("\(token) is not expected")
            }
        }
    }
    
    func parseDocument() throws -> OrgNode {
        let document = OrgNode(value: DocumentMeta())
        
        while let token = tokens.peek() {
            switch token {
            case let .Setting(_, key, value):
                tokens.dequeue()
                if var meta = document.value as? DocumentMeta {
                    meta.settings[key] = value
                    document.value = meta
                }
            //                doc.settings[key] = value
            default:
                try parseSection(document)
            }
        }
        //        document.value = doc
        return document
    }
    
    // MARK: helpers
    func getCurrentLevel(node: OrgNode) -> Int {
        if let section = node.value as? Section {
            return section.level
        }
        if let p = node.parent {
            return getCurrentLevel(p)
        }
        return 0
    }
    
    func getTodos(node: OrgNode) -> [String] {
        if let doc = node.lookUp(DocumentMeta) {
            return doc.todos
        }
        // TODO make it robust
        print("+++ Cannot find DocumentMeta")
        return []
    }
    
    
    public func parse() throws -> OrgNode {
        return try parseDocument()
    }
}
