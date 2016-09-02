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
    var tokens: Queue<Token>
    
    public init(tokens: [Token]) {
        self.tokens = Queue<Token>(data: tokens)
    }
    
    func parseBlock() throws -> Block {
        guard case let Token.BlockBegin(type, params) = tokens.dequeue()! else {
            throw Errors.UnexpectedToken("BlockBegin expected")
        }
        var block = Block(type: type, params: params)
        while let token = tokens.dequeue() {
            switch token {
            case let .Raw(text):
                block.content.append(text)
            case let .BlockEnd(t):
                if t.lowercaseString != type.lowercaseString {
                    throw Errors.UnexpectedToken("Expecting BlockEnd of type \(type), but got \(t)")
                }
                return block
            default:
                throw Errors.UnexpectedToken("Expecting Raw or BlockEnd, but got \(token)")
            }
        }
        throw Errors.UnexpectedToken("Cannot find BlockEnd")
    }
    
    func parseLines() throws -> Paragraph {
        guard case Token.Line(let text) = tokens.dequeue()! else {
            throw Errors.UnexpectedToken("Line expected")
        }
        var line = Paragraph(lines: [text])
        while let token = tokens.peek() {
            if case .Line(let t) = token {
                line.lines.append(t)
                tokens.dequeue()
            } else {
                break
            }
        }
        return line
    }
    
    func getCurrentLevel(node: OrgNode) -> Int {
        if let section = node.value as? Section {
            return section.level
        }
        if let p = node.parent {
            return getCurrentLevel(p)
        }
        return 0
    }
    
    func parseSection(parent: OrgNode) throws {
        while let token = tokens.peek() {
            switch token {
            case let .Header(l, t, s):
                if l <= getCurrentLevel(parent) {
                    return
                }
                tokens.dequeue()
                let subSection = parent.add(Section(level: l, title: t!, state: s))
                try parseSection(subSection)
            case .Blank:
                tokens.dequeue()
                parent.add(Blank())
            case .Line:
                parent.add(try parseLines())
            case let .Comment(t):
                tokens.dequeue()
                parent.add(Comment(text: t))
            case .BlockBegin:
                parent.add(try parseBlock())
            default:
                throw Errors.UnexpectedToken("\(token) is not expected")
            }
        }
    }
    
    func parseDocument() throws -> OrgNode {
        var doc = DocumentMeta()
        let document = OrgNode(value: doc)
        
        while let token = tokens.peek() {
            switch token {
            case let .Setting(key, value):
                tokens.dequeue()
                doc.settings[key] = value
            default:
                try parseSection(document)
            }
        }
        document.value = doc
        return document
    }
    
    public func parse() throws -> OrgNode {
        return try parseDocument()
    }
}