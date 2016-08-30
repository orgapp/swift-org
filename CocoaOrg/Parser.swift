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
    let tokens: [Token]
    var index = 0
    
    public init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    func peekCurrentToken() -> Token? {
        if index >= tokens.count {
            return nil
        }
        return tokens[index]
    }
    
    func popCurrentToken() -> Token? {
        index += 1
        if index > tokens.count {
            return nil
        }
        return tokens[index - 1]
    }
    
    func parseBlock() throws -> Block {
        guard case let Token.BlockBegin(type, params) = popCurrentToken()! else {
            throw Errors.UnexpectedToken("BlockBegin expected")
        }
        var block = Block(type: type, params: params)
        while let token = popCurrentToken() {
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
    
    func parseLines() throws -> Line {
        guard case Token.Line(let text) = popCurrentToken()! else {
            throw Errors.UnexpectedToken("Line expected")
        }
        var line = Line(text: text)
        while let token = peekCurrentToken() {
            if case .Line(let t) = token {
                line.text = [line.text, t].joinWithSeparator(" ")
                popCurrentToken()
            } else {
                break
            }
        }
        return line
    }
    
    func parseSection(level: Int) throws -> [Node] {
        var nodes = [Node]()
        while let token = peekCurrentToken() {
            switch token {
            case let .Header(l, t, s):
                if l <= level {
                    return nodes
                }
                popCurrentToken()
                var subSection = Section(level: l, title: t!, state: s)
                subSection.nodes = try parseSection(l)
                nodes.append(subSection)
            case .Blank:
                popCurrentToken()
                nodes.append(Blank())
            case .Line:
                nodes.append(try parseLines())
            case let .Comment(t):
                popCurrentToken()
                nodes.append(Comment(text: t))
            case .BlockBegin:
                nodes.append(try parseBlock())
            default:
                throw Errors.UnexpectedToken("\(token) is not expected")
            }
        }
        return nodes
    }
    
    func parseDocument() throws -> Document {
        var document = Document()
        while let token = peekCurrentToken() {
            switch token {
            case let .Setting(key, value):
                popCurrentToken()
                document.settings = (document.settings ?? [key: value])
            default:
                let section = try parseSection(0)
                document.nodes += section
            }
        }
        return document
    }
    
    public func parse() throws -> Document {
        return try parseDocument()
    }
}