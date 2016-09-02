//
//  Lexer.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 14/08/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public enum Token {
    case Setting(key: String, value: String)
    case Header(level: Int, text: String?)
    case Blank
    case HorizontalRule
    case BlockBegin(type: String, params: [String]?)
    case BlockEnd(type: String)
    case UnorderedListItem(text: String)
    case OrderedListItem(text: String)
    case Comment(String?)
    case Line(text: String)
    case Raw(String)
}

typealias TokenGenerator = ([String?]) -> Token?
let tokenList: [(String, NSRegularExpressionOptions, TokenGenerator)] = [
    ("^\\s*$", [], { _ in .Blank }),
    ("^#\\+([a-zA-Z_]+):\\s*(.*)$", [],
        { matches in .Setting(key: matches[1]!, value: matches[2]!) }),
//    ("^(\\*+)\\s+(?:(TODO|DONE)\\s+)?(.*)$", [],
    ("^(\\*+)\\s+(.*)$", [],
        { matches in .Header(level: matches[1]!.characters.count, text: matches[2]) }),
    ("^(\\s*)#\\+begin_([a-z]+)(:?\\s+(.*))?$", [.CaseInsensitive],
        { (matches: [String?]) in
            .BlockBegin(
                type: matches[2]!,
                params: matches[3] != nil ? matches[3]!.characters.split{$0 == " "}.map(String.init) : nil) }),
    ("^(\\s*)#\\+end_([a-z]+)$", [.CaseInsensitive],
        { matches in .BlockEnd(type: matches[2]!) }),
    ("^\\s*-{5,}$", [], { _ in .HorizontalRule }),
    ("^\\s*#\\s+(.*)$", [],
        { matches in .Comment(matches[1]) }),
    ("^(\\s*)(.*)$", [],
        { matches in .Line(text: matches[2]!)})
]

public class Lexer {
    let lines: [String]
    var cursor: Int
    var tokens: [Token]
    var buffer: [Token]
    public init(lines ls: [String]) {
        lines = ls
        cursor = 0
        tokens = [Token]()
        buffer = [Token]()
    }
    
    private func tokenize(line: String) -> Token {
        for (pattern, options, generator) in tokenList {
            if let m = line.match(pattern, options: options) {
                if let token = generator(m) {
                    return token
                }
            }
        }
        return .Raw(line)
    }
    
    private func tryTokenize(match: (Token) -> Bool, or: (String) -> Token) -> Bool {
        if cursor == lines.count {
            return false
        }
        let line = lines[cursor]
        let token = tokenize(line)
        if match(token) {
            buffer.append(token)
            return true
        } else {
            buffer.append(or(line))
            cursor += 1
            return tryTokenize(match, or: or)
        }
    }
    
    public func reset() {
        cursor = 0
    }
    
    public func tokenize() -> [Token] {
        if cursor == self.lines.count {
            return tokens
        }
        
        let line = lines[cursor]
        let token = tokenize(line)
        
        switch token {
        case let .BlockBegin(beginType, _):
            let currentCursor = cursor
            cursor += 1
            buffer.removeAll()
            if tryTokenize({t in
                if case let .BlockEnd(endType) = t {
                    return beginType.lowercaseString == endType.lowercaseString
                }
                return false
                }, or: {l in .Raw(l)}) {
                tokens.append(token)
                tokens += buffer
            } else {
                tokens.append(.Line(text: line))
                cursor = currentCursor
            }
        default:
            tokens.append(token)
        }
        cursor += 1
        return tokenize()
    }
}