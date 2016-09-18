//
//  Parser.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 22/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public enum Errors: Error {
    case unexpectedToken(String)
}

open class Parser {
    // MARK: properties
    var tokens: Queue<TokenWithMeta>
    
    // MARK: init
    init(tokens: [TokenWithMeta]) {
        self.tokens = Queue<TokenWithMeta>(data: tokens)
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
        guard case let (meta, Token.blockBegin(name, params)) = tokens.dequeue()! else {
            throw Errors.unexpectedToken("BlockBegin expected")
        }
        var block = Block(name: name, params: params)
        tokens.takeSnapshot()
        while let (m, token) = tokens.dequeue() {
            switch token {
            case let .blockEnd(n):
                if n.lowercased() != name.lowercased() {
                    throw Errors.unexpectedToken("Expecting BlockEnd of type \(name), but got \(n)")
                }
                return block
            default:
                block.content.append(m.raw ?? "")
            }
        }
        tokens.restore()
        return try self.parseLines(meta.raw?.trimmed)
    }
    
    func parseList() throws -> List {
        guard case let (_, Token.listItem(indent, text, ordered)) = tokens.dequeue()! else {
            throw Errors.unexpectedToken("ListItem expected")
        }
        var list = List(ordered: ordered)
        list.items = [ListItem(text: text)]
        while let (_, token) = tokens.peek() {
            if case let .listItem(i, t, _) = token {
                if i > indent {
                    var lastItem = list.items.removeLast()
                    lastItem.list = try parseList()
                    list.items += [lastItem]
                } else if i == indent {
                    _ = tokens.dequeue()
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
    
    func parseLines(_ startWith: String? = nil) throws -> Paragraph {
        guard case (_, .line(let text)) = tokens.dequeue()! else {
            throw Errors.unexpectedToken("Line expected")
        }
        var line = Paragraph(lines: [text])
        if let firstLine = startWith {
            line.lines.insert(firstLine, at: 0)
        }
        while let (_, token) = tokens.peek() {
            if case .line(let t) = token {
                line.lines.append(t)
                _ = tokens.dequeue()
            } else {
                break
            }
        }
        return line
    }
    
    func lookForDrawers() throws -> [Drawer]? {
        if tokens.isEmpty {
            return nil
        }
        guard case let (meta, .drawerBegin(name)) = tokens.peek()! else {
            return nil
        }
        tokens.takeSnapshot()
        var content: [String] = []
        while let (m, token) = tokens.dequeue() {
            if case .drawerEnd = token {
                var result = [Drawer(name, content: content)]
                if let drawers = try lookForDrawers() {
                    result.append(contentsOf: drawers)
                }
                return result
            }
            content.append(m.raw ?? "")
        }
        tokens.restore()
        tokens.swapNext(with: (meta, .line(text: (meta.raw?.trimmed)!)))
        return nil
    }
    
    func parseSection(_ parent: OrgNode) throws {
        while let (_, token) = tokens.peek() {
            switch token {
            case let .headline(l, t):
                if l <= getCurrentLevel(parent) {
                    return
                }
                _ = tokens.dequeue()
                var sec = Section(level: l, title: t, todos: getTodos(parent))
                sec.drawers = try lookForDrawers()
                let subSection = parent.add(sec)
                try parseSection(subSection)
            case .blank:
                _ = tokens.dequeue()
                _ = parent.add(Blank())
            case .line:
                _ = parent.add(try parseLines())
            case let .comment(t):
                _ = tokens.dequeue()
                _ = parent.add(Comment(text: t))
            case .blockBegin:
                _ = parent.add(try parseBlock())
            case .listItem:
                _ = parent.add(try parseList())
            case .drawerBegin, .drawerEnd:
                _ = tokens.dequeue() // discard non-functional drawers
//                tokens.swapNext(with: (meta, .line(text: (meta.raw?.trimmed)!)))
            default:
                throw Errors.unexpectedToken("\(token) is not expected")
            }
        }
    }
    
    func parseDocument() throws -> OrgNode {
        let document = OrgNode(value: DocumentMeta())
        
        while let (_, token) = tokens.peek() {
            switch token {
            case let .setting(key, value):
                _ = tokens.dequeue()
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
    func getCurrentLevel(_ node: OrgNode) -> Int {
        if let section = node.value as? Section {
            return section.level
        }
        if let p = node.parent {
            return getCurrentLevel(p)
        }
        return 0
    }
    
    func getTodos(_ node: OrgNode) -> [String] {
        if let doc = node.lookUp(DocumentMeta.self) {
            return doc.todos
        }
        // TODO make it robust
        print("+++ Cannot find DocumentMeta")
        return []
    }
    
    
    open func parse() throws -> OrgNode {
        return try parseDocument()
    }
}
