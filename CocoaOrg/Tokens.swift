//
//  Tokens.swift
//  CocoaOrg
//
//  Created by Xiaoxing Hu on 13/09/16.
//  Copyright © 2016 Xiaoxing Hu. All rights reserved.
//

import Foundation

public struct TokenMeta {
    public let raw: String?
    public let lineNumber: Int
}

protocol CommonToken {
    var meta: TokenMeta {get}
}

public enum Token {
    case Setting(TokenMeta, key: String, value: String?)
    case Header(TokenMeta, level: Int, text: String?)
    case Blank(TokenMeta)
    case HorizontalRule(TokenMeta)
    case BlockBegin(TokenMeta, type: String, params: [String]?)
    case BlockEnd(TokenMeta, type: String)
    case ListItem(TokenMeta, indent: Int, text: String?, ordered: Bool)
    case Comment(TokenMeta, String?)
    case Line(TokenMeta, text: String)
    case Raw(TokenMeta)
}

extension Token: CommonToken {
    var meta: TokenMeta {
        switch self {
        case .Setting(let meta, _, _):
            return meta
        case .Header(let meta, _, _):
            return meta
        case .Blank(let meta):
            return meta
        case .HorizontalRule(let meta):
            return meta
        case .BlockBegin(let meta, _, _):
            return meta
        case .BlockEnd(let meta, _):
            return meta
        case .ListItem(let meta, _, _, _):
            return meta
        case .Comment(let meta, _):
            return meta
        case .Line(let meta, _):
            return meta
        case .Raw(let meta):
            return meta
        }
    }
}

typealias TokenGenerator = ([String?], Int) -> Token?

var tokenList: [(String, NSRegularExpressionOptions, TokenGenerator)] = []

func define(pattern: String, options: NSRegularExpressionOptions = [], generator: TokenGenerator) {
    tokenList += [
        (pattern, options, generator)
    ]
}

func defineTokens() {
    if tokenList.count > 0 {return}
    
    define("^\\s*$") { matches, lineNumber in
        .Blank(TokenMeta(raw: matches[0], lineNumber: lineNumber)) }
    define("^#\\+([a-zA-Z_]+):\\s*(.*)$") { matches, lineNumber in
        .Setting(TokenMeta(raw: matches[0], lineNumber: lineNumber), key: matches[1]!, value: matches[2]) }
    define("^(\\*+)\\s+(.*)$") { matches, lineNumber in
        .Header(TokenMeta(raw: matches[0], lineNumber: lineNumber),
                level: matches[1]!.characters.count, text: matches[2]) }
    define("^(\\s*)#\\+begin_([a-z]+)(:?\\s+(.*))?$", options: [.CaseInsensitive]) { matches, lineNumber in
        var params: [String]?
        let meta = TokenMeta(raw: matches[0], lineNumber: lineNumber)
        if let m3 = matches[3] {
            params = m3.characters.split{$0 == " "}.map(String.init)
        }
        return .BlockBegin(meta, type: matches[2]!, params: params) }
    define("^(\\s*)#\\+end_([a-z]+)$", options: [.CaseInsensitive]) { matches, lineNumber in
        .BlockEnd(TokenMeta(raw: matches[0], lineNumber: lineNumber), type: matches[2]!) }
    define("^(\\s*)[-+*]\\s+(.*)$") { matches, lineNumber in
        .ListItem(TokenMeta(raw: matches[0], lineNumber: lineNumber),
                  indent: length(matches[1]), text: matches[2], ordered: false) }
    define("^(\\s*)\\d+(?:\\.|\\))\\s+(.*)$") { matches, lineNumber in
        .ListItem(TokenMeta(raw: matches[0], lineNumber: lineNumber), indent: length(matches[1]), text: matches[2], ordered: true) }
    define("^\\s*-{5,}$") { matches, lineNumber in
        .HorizontalRule(TokenMeta(raw: matches[0]!, lineNumber: lineNumber)) }
    define("^\\s*#\\s+(.*)$") { matches, lineNumber in
        .Comment(TokenMeta(raw: matches[0], lineNumber: lineNumber), matches[1]) }
    define("^(\\s*)(.*)$") { matches, lineNumber in
        .Line(TokenMeta(raw: matches[0], lineNumber: lineNumber), text: matches[2]!) }
}