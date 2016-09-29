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

public class OrgParser {
    // MARK: properties
    var tokens: Queue<TokenWithMeta>!
    var document: OrgDocument!
    
    // MARK: init
    public init() {}
    
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
        return try self.parseLines(meta.raw?.trimmed)!
    }
    
    func parseList() throws -> List {
        guard case let (_, Token.listItem(indent, text, ordered, checked)) = tokens.dequeue()! else {
            throw Errors.unexpectedToken("ListItem expected")
        }
        var list = List(ordered: ordered)
        list.items = [ListItem(text: text, checked: checked)]
        while let (_, token) = tokens.peek() {
            if case let .listItem(i, t, _, c) = token {
                if i > indent {
                    var lastItem = list.items.removeLast()
                    lastItem.subList = try parseList()
                    list.items += [lastItem]
                } else if i == indent {
                    _ = tokens.dequeue()
                    list.items += [ListItem(text: t, checked: c)]
                } else {
                    break
                }
            } else {
                break
            }
        }
        
        return list
    }
    
    func parseLines(_ startWith: String? = nil) throws -> Paragraph? {
        var paragraph: Paragraph? = nil
        if let firstLine = startWith {
            paragraph = Paragraph(lines: [firstLine])
        }
        while let (_, token) = tokens.peek() {
            if case .line(let t) = token {
                paragraph = paragraph ?? Paragraph(lines: [])
                paragraph?.lines.append(t)
                _ = tokens.dequeue()
            } else {
                break
            }
        }
        return paragraph
    }
    
    func lookForDrawers() throws -> [Drawer]? {
        if tokens.isEmpty {
            return nil
        }
        guard case let (meta, .drawerBegin(name)) = tokens.peek()! else {
            return nil
        }
        tokens.takeSnapshot()
        _ = tokens.dequeue()
        var content: [String] = []
        while let (m, token) = tokens.dequeue() {
            if case .drawerEnd = token {
                var result = [Drawer(name, content: content)]
                if let drawers = try lookForDrawers() {
                    result.append(contentsOf: drawers)
                }
                return result
            }
            content.append((m.raw ?? "").trimmed)
        }
        tokens.restore()
        tokens.swapNext(with: (meta, .line(text: (meta.raw?.trimmed)!)))
        return nil
    }
    
    func parseFootnote() throws -> Footnote {
        guard case let (_, .footnote(label, content)) = tokens.dequeue()! else {
            throw Errors.unexpectedToken("footnote expected")
        }
        
        var footnote = Footnote(label: label, content: [try parseLines(content)!])
        while let (_, token) = tokens.peek() {
            switch token {
            case .headline, .footnote:
                return footnote
            default:
                if let n = try parseTheRest() {
                    footnote.content.append(n)
                }
            }
        }
        return footnote
    }
    
    func parseTheRest() throws -> Node? {
        guard let (_, token) = tokens.peek() else {
            return nil
        }
        switch token {
        case .blank:
            _ = tokens.dequeue()
            return nil
        case .line:
            return try parseLines()
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
    
    func parseSection(_ currentLevel: Int = 0) throws -> Node? {
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
    
    func parseDocument() throws -> OrgDocument {
        while let (_, token) = tokens.peek() {
            switch token {
            case let .setting(key, value):
                _ = tokens.dequeue()
                document.settings[key] = value
            default:
                if let node = try parseSection() {
                    document.content.append(node)
                }
            }
        }
        return document
    }
    
    // MARK: parse document
    func parse(tokens: [TokenWithMeta]) throws -> OrgDocument {
        self.tokens = Queue<TokenWithMeta>(data: tokens)
        document = OrgDocument()
        return try parseDocument()
    }
    
    public func parse(lines: [String]) throws -> OrgDocument {
        let lexer = Lexer(lines: lines)
        return try parse(tokens: lexer.tokenize())
    }
    
    public func parse(content: String) throws -> OrgDocument {
        return try parse(lines: content.lines)
    }
}
